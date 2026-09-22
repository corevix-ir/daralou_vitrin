package Services

import (
	"path/filepath"
	"strings"
)

// ToPublicImageURL rewrites a value stored in the DB for an image into a URL
// the frontend can actually fetch over HTTP via /static. Two things can end
// up in these columns:
//   - A value already correct: an absolute http(s) URL, or a "/static/..."
//     path (e.g. what Service/Upload.go's SaveImage returns).
//   - A historical bug: the raw absolute filesystem path the scraper used to
//     os.Create() the file with (see Scraper/NewsDaralou.go DownloadAsset),
//     which is meaningless to a browser.
//
// This is shared by contentService and vitrineService so both read paths
// normalize the same way regardless of which bug-era wrote the row.
func ToPublicImageURL(baseImagePath, stored string) string {
	if stored == "" {
		return ""
	}
	if strings.HasPrefix(stored, "http://") || strings.HasPrefix(stored, "https://") || strings.HasPrefix(stored, "/static/") {
		return stored
	}

	rel := stored
	if baseImagePath != "" && strings.HasPrefix(stored, baseImagePath) {
		rel = strings.TrimPrefix(stored, baseImagePath)
	}
	rel = strings.TrimPrefix(filepath.ToSlash(rel), "/")

	return "/static/" + rel
}
