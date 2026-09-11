import os

PCK_PATH = "Builds/index.pck"
CHUNKS_DIR = "Builds/"
CHUNK_SIZE = 25 * 1024 * 1024 # Пилим строго по 25 Мегабайт

def split_pck():
    if not os.path.exists(PCK_PATH):
        print("❌ Ошибка: Файл index.pck не найден!")
        return

    print("⚡ Запуск распила index.pck...")
    with open(PCK_PATH, "rb") as f:
        chunk_num = 0
        while True:
            chunk_data = f.read(CHUNK_SIZE)
            if not chunk_data:
                break
            chunk_name = f"index.pck.part{chunk_num:02d}"
            with open(os.path.join(CHUNKS_DIR, chunk_name), "wb") as chunk_file:
                chunk_file.write(chunk_data)
            print(f"✅ Создана часть: {chunk_name}")
            chunk_num += 1

    # Удаляем оригинальный тяжелый файл ресурсов
    os.remove(PCK_PATH)
    print("🗑️ Оригинальный index.pck успешно удален!")

if __name__ == "__main__":
    split_pck()
