package Scraper

import (
	"fmt"
	"net/url"
	"regexp"
	"strconv"
	"strings"
	"time"

	ptime "github.com/yaa110/go-persian-calendar"
)

var (
	idRegex        = regexp.MustCompile(`(\d+)\s*$`)
	thumbnailRegex = regexp.MustCompile(`/thumbnail/[^/]+/`)
	spaceRegex     = regexp.MustCompile(`[ \t]+`)
)

// extractID pulls the trailing numeric id out of a news href.
// ".../عنوان-خبر/21915" -> "21915"
func extractID(href string) string {
	m := idRegex.FindStringSubmatch(strings.TrimSpace(href))
	if len(m) == 2 {
		return m[1]
	}
	return ""
}

// normalizeDigits converts Persian (۰-۹) and Arabic-Indic (٠-٩) digits to ASCII.
// Needed because some image URLs on the source use Persian digits in the path.
func normalizeDigits(s string) string {
	var b strings.Builder
	for _, r := range s {
		switch {
		case r >= '۰' && r <= '۹': // U+06F0..U+06F9
			b.WriteRune('0' + (r - '۰'))
		case r >= '٠' && r <= '٩': // U+0660..U+0669
			b.WriteRune('0' + (r - '٠'))
		default:
			b.WriteRune(r)
		}
	}
	return b.String()
}

// cleanText normalizes whitespace and non-breaking spaces while preserving
// ZWNJ (نیم‌فاصله) and paragraph line breaks.
func cleanText(s string) string {
	s = strings.ReplaceAll(s, "\u00a0", " ") // nbsp -> space
	s = strings.ReplaceAll(s, "\r\n", "\n")
	s = strings.ReplaceAll(s, "\r", "\n")
	lines := strings.Split(s, "\n")
	out := make([]string, 0, len(lines))
	for _, ln := range lines {
		ln = strings.TrimSpace(spaceRegex.ReplaceAllString(ln, " "))
		out = append(out, ln)
	}
	return strings.TrimSpace(strings.Join(out, "\n"))
}

// stripThumbnail turns a thumbnail path into its full-resolution equivalent.
// "/thumbnail/660-440/uploads/x.jpg" -> "/uploads/x.jpg"
func stripThumbnail(src string) string {
	return thumbnailRegex.ReplaceAllString(src, "/")
}

// resolveURL resolves a possibly-relative ref against base and returns a
// properly-encoded absolute URL string.
func resolveURL(base, ref string) (string, error) {
	b, err := url.Parse(base)
	if err != nil {
		return "", err
	}
	r, err := url.Parse(ref)
	if err != nil {
		return "", err
	}
	return b.ResolveReference(r).String(), nil
}

// parseJalaliDateTime parses strings like "1405/03/27 - 09:12" (Jalali) into a
// Gregorian time.Time in the Asia/Tehran zone.
func parseJalaliDateTime(s string) (time.Time, error) {
	s = normalizeDigits(strings.TrimSpace(s))

	datePart := s
	timePart := ""
	if idx := strings.Index(s, "-"); idx >= 0 {
		datePart = strings.TrimSpace(s[:idx])
		timePart = strings.TrimSpace(s[idx+1:])
	}

	dp := strings.Split(datePart, "/")
	if len(dp) != 3 {
		return time.Time{}, fmt.Errorf("unexpected jalali date: %q", s)
	}
	y, err1 := strconv.Atoi(strings.TrimSpace(dp[0]))
	m, err2 := strconv.Atoi(strings.TrimSpace(dp[1]))
	d, err3 := strconv.Atoi(strings.TrimSpace(dp[2]))
	if err1 != nil || err2 != nil || err3 != nil {
		return time.Time{}, fmt.Errorf("invalid jalali date: %q", s)
	}

	hh, mm := 0, 0
	if timePart != "" {
		tp := strings.Split(timePart, ":")
		if len(tp) >= 2 {
			hh, _ = strconv.Atoi(strings.TrimSpace(tp[0]))
			mm, _ = strconv.Atoi(strings.TrimSpace(tp[1]))
		}
	}

	loc, err := time.LoadLocation("Asia/Tehran")
	if err != nil {
		loc = time.FixedZone("IRST", 3*3600+1800) // UTC+03:30 fallback
	}

	pt := ptime.Date(y, ptime.Month(m), d, hh, mm, 0, 0, loc)
	return pt.Time(), nil
}
