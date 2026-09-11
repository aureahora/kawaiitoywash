import os

BUILDS_DIR = "Builds/"
CHUNK_SIZE = 25 * 1024 * 1024  # Пилим по 25 МБ

def split_to_png(filename):
    file_path = os.path.join(BUILDS_DIR, filename)
    if not os.path.exists(file_path):
        return

    print(f"⚡ Маскировка {filename} под PNG...")
    with open(file_path, "rb") as f:
        chunk_num = 0
        while True:
            chunk_data = f.read(CHUNK_SIZE)
            if not chunk_data:
                break
            # Маскируем расширение строго под .png
            chunk_name = f"{filename}_data_{chunk_num:02d}.png"
            with open(os.path.join(BUILDS_DIR, chunk_name), "wb") as chunk_file:
                chunk_file.write(chunk_data)
            print(f"   ✅ Создан файл: {chunk_name}")
            chunk_num += 1

    os.remove(file_path)

if __name__ == "__main__":
    split_to_png("index.pck")
    split_to_png("index.wasm")
    print("🎉 Маскировка под картинки успешно завершена!")
