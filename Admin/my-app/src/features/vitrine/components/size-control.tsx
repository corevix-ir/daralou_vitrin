const MIN_SIZE = 1;
const MAX_SIZE = 20;

export function SizeControl({ size, onChange }: { size: number; onChange: (size: number) => void }) {
  function set(next: number) {
    onChange(Math.min(MAX_SIZE, Math.max(MIN_SIZE, next)));
  }

  return (
    <div className="flex items-center gap-2">
      <span className="text-[13px] font-medium text-slate-600 dark:text-slate-300">تعداد جایگاه‌ها</span>
      <div className="flex items-center rounded-md border border-slate-300 dark:border-slate-700">
        <button
          type="button"
          onClick={() => set(size - 1)}
          disabled={size <= MIN_SIZE}
          className="flex size-8 items-center justify-center text-slate-600 hover:bg-slate-50 disabled:opacity-40 dark:text-slate-300 dark:hover:bg-slate-800 cursor-pointer"
        >
          −
        </button>
        <input
          type="number"
          min={MIN_SIZE}
          max={MAX_SIZE}
          value={size}
          onChange={(event) => set(Number(event.target.value) || MIN_SIZE)}
          className="h-8 w-12 border-x border-slate-300 bg-white text-center text-[13px] outline-none dark:border-slate-700 dark:bg-slate-900"
        />
        <button
          type="button"
          onClick={() => set(size + 1)}
          disabled={size >= MAX_SIZE}
          className="flex size-8 items-center justify-center text-slate-600 hover:bg-slate-50 disabled:opacity-40 dark:text-slate-300 dark:hover:bg-slate-800 cursor-pointer"
        >
          +
        </button>
      </div>
    </div>
  );
}
