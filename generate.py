import os
import re
from pathlib import Path
from PIL import Image, ImageFilter

# ─────────────────────────────────────────────
BLUR = 25  # 0 = no blur, 18 = max. change and rerun anytime.
# ─────────────────────────────────────────────

STORIES_DIR   = Path('stories')
PROCESSED_DIR = Path('processed')
INDEX         = Path('index.html')
IMAGE_EXTS    = {'.jpg', '.jpeg', '.png', '.webp'}
VIDEO_EXTS    = set()

def collect_files():
    files = []
    for root, dirs, filenames in os.walk(STORIES_DIR):
        dirs.sort()
        for f in sorted(filenames):
            ext = Path(f).suffix.lower()
            if ext in IMAGE_EXTS or ext in VIDEO_EXTS:
                files.append(Path(root) / f)
    return files

def process_image(src, dest):
    dest.parent.mkdir(parents=True, exist_ok=True)
    img = Image.open(src).convert('RGB')
    if BLUR > 0:
        img = img.filter(ImageFilter.GaussianBlur(radius=BLUR))
    img.save(dest, 'WEBP', quality=80)

def main():
    if not STORIES_DIR.exists():
        print(f"Error: '{STORIES_DIR}' folder not found.")
        return

    files = collect_files()
    if not files:
        print('No media files found in stories/')
        return

    PROCESSED_DIR.mkdir(exist_ok=True)
    processed_paths = []

    for i, file in enumerate(files, 1):
        ext = file.suffix.lower()
        relative = file.relative_to(STORIES_DIR)
        print(f'\r{i}/{len(files)} — {file.name}', end='', flush=True)

        if ext in VIDEO_EXTS:
            dest = PROCESSED_DIR / relative
            dest.parent.mkdir(parents=True, exist_ok=True)
            import shutil
            shutil.copy2(file, dest)
            processed_paths.append(str(dest).replace('\\', '/'))
        else:
            dest = (PROCESSED_DIR / relative).with_suffix('.webp')
            process_image(file, dest)
            processed_paths.append(str(dest).replace('\\', '/'))

    # update index.html
    lines = '\n'.join(f'  "{p}",' for p in processed_paths)
    html = INDEX.read_text(encoding='utf-8')
    html = re.sub(
        r'// FILES_START.*?// FILES_END',
        f'// FILES_START\n{lines}\n  // FILES_END',
        html,
        flags=re.DOTALL
    )
    INDEX.write_text(html, encoding='utf-8')

    print(f'\n\nDone — {len(files)} files processed (blur: {BLUR})')
    print('Now run: git add . && git commit -m "update" && git push')

if __name__ == '__main__':
    main()