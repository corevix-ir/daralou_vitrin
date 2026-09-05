import { SlotCard } from "./slot-card";
import type { SlotMap } from "../model/vitrine.types";

export function SlotGrid({
  size,
  slots,
  onPick,
  onClear,
}: {
  size: number;
  slots: SlotMap;
  onPick: (position: number) => void;
  onClear: (position: number) => void;
}) {
  const positions = Array.from({ length: size }, (_, index) => index + 1);

  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5">
      {positions.map((position) => (
        <SlotCard
          key={position}
          position={position}
          item={slots[position] ?? null}
          onPick={() => onPick(position)}
          onClear={() => onClear(position)}
        />
      ))}
    </div>
  );
}
