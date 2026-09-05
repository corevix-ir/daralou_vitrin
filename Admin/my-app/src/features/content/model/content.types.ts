export type ContentSource = "daralouWeb" | "daralouOperator";

export interface ContentSummary {
  id: number;
  title: string;
  summary: string | null;
  main_img: string;
  created_at: string;
}

export interface ContentListResponse {
  content: ContentSummary[];
  total: number;
  page: number;
  size: number;
}

export interface ContentDetail {
  id: number;
  content_type: string;
  title: string;
  body: string;
  summary: string | null;
  main_img_url: string;
  extra_img_list: string[];
  external_url: string;
  source: ContentSource;
  start_date: string | null;
  end_date: string | null;
  is_published: boolean;
  created_by: number;
  // Backend quirk: these two fields break the snake_case convention of the rest
  // of the payload — see vitrine-admin-api.md §4.4.
  CreatedAt: string;
  UpdatedAt: string;
}

export interface CreateContentPayload {
  title: string;
  body: string;
  summary?: string;
  main_img: string;
  img_list: string[];
  device_id: number[];
  start_date?: string | null;
  end_date?: string | null;
}

/** Local content only — scraped content rejects PUT/DELETE outright. Assignment
 * (`device_id`) can't be changed after creation — see admin-panel-api.md §4. */
export interface UpdateContentPayload {
  title?: string;
  body?: string;
  summary?: string;
  main_img?: string;
  img_list?: string[];
  start_date?: string | null;
  end_date?: string | null;
}
