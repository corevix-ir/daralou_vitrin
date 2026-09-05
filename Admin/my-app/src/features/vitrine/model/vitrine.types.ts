import type { ContentSource, ContentSummary } from "@/features/content/model/content.types";

export interface VitrineItem {
  position: number;
  source: ContentSource;
  content: ContentSummary;
}

export interface VitrineConfig {
  size: number;
  items: VitrineItem[];
}

export interface VitrineSaveItem {
  position: number;
  content_id: number;
}

export interface VitrineSavePayload {
  size: number;
  items: VitrineSaveItem[];
}

export interface VitrinePreviewItem extends VitrineItem {
  is_auto: boolean;
}

export interface VitrinePreview {
  items: VitrinePreviewItem[];
}

/** Editor's in-memory view of one slot — `null` means "leave empty / auto-fill". */
export type SlotMap = Record<number, VitrineItem | null>;
