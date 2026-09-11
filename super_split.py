import os

BUILDS_DIR = "Builds/"
CHUNK_SIZE = 25 * 1024 * 1024  # Пилим строго по 25 МБ

def split_file(filename):
    file_path = os.path.join(BUILDS_DIR, filename)
    if not os.path.exists(file_path):
        print(f"⚠️ Файл {filename} не найден, пропускаем.")
        return

    print(f"⚡ Распил {filename}...")
    with open(file_path, "rb") as f:
        chunk_num = 0
        while True:
            chunk_data = f.read(CHUNK_SIZE)
            if not chunk_data:
                break
            chunk_name = f"{filename}.part{chunk_num:02d}"
            with open(os.path.join(BUILDS_DIR, chunk_name), "wb") as chunk_file:
                chunk_file.write(chunk_data)
            print(f"   ✅ Создана часть: {chunk_name}")
            chunk_num += 1

    os.remove(file_path)
    print(f"🗑️ Оригинальный {filename} удален!")

if __name__ == "__main__":
    split_file("index.pck")
    split_file("index.wasm")
    print("🎉 Тотальный распил успешно завершен!")
