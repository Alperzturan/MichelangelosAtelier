"""
Michelangelo's Atelier - Veritabanı Tohumlama (Seed) Betiği
Rönesans ve Barok dönemlerine ait kategoriler, başyapıtlar ve örnek kullanıcılar ekler.
"""
import sys
from pathlib import Path

# Add api folder to sys.path
sys.path.insert(0, str(Path(__file__).resolve().parent))

from app.core.database import SessionLocal
from app.core.security import get_password_hash
from app.models.user import User
from app.models.category import Category
from app.models.artwork import Artwork

def seed_database():
    db = SessionLocal()
    try:
        print("Veritabanı tohumlama işlemi başlatılıyor...")

        # 1. Kullanıcılar (Admin ve Standart Kullanıcı)
        admin_user = db.query(User).filter(User.email == "admin@atelier.com").first()
        if not admin_user:
            admin_user = User(
                full_name="Michelangelo Buonarroti",
                email="admin@atelier.com",
                password_hash=get_password_hash("admin123"),
                role="admin",
            )
            db.add(admin_user)
            print("Admin kullanıcısı oluşturuldu: admin@atelier.com / admin123")

        orhan_user = db.query(User).filter(User.email == "orhan@atelier.com").first()
        if not orhan_user:
            orhan_user = User(
                full_name="Orhan Yağız Türedi",
                email="orhan@atelier.com",
                password_hash=get_password_hash("orhan123"),
                role="user",
            )
            db.add(orhan_user)
            print("Örnek kullanıcı oluşturuldu: orhan@atelier.com / orhan123")

        db.commit()

        # 2. Kategoriler
        categories_data = [
            {
                "name": "Yüksek Rönesans",
                "description": "15. yüzyıl sonu ile 16. yüzyıl başı İtalyan sanatının zirve dönemi; kusursuz anatomi, kompozisyon ve perspektif uyumu."
            },
            {
                "name": "Heykel Sanatı",
                "description": "Mermer ve bronzun usta ellerde hayat bulduğu üç boyutlu klasik başyapıtlar."
            },
            {
                "name": "Barok",
                "description": "17. yüzyıl Avrupa'sında ortaya çıkan, dramatik ışık-gölge (chiaroscuro) kullanımı ve yoğun duygusal anlatımıyla öne çıkan sanat akımı."
            },
            {
                "name": "Fresk & Tavan Resmi",
                "description": "Yaş sıva üzerine yapılan anıtsal duvar ve tavan süsleme resimleri."
            },
        ]

        category_map = {}
        for cat_info in categories_data:
            cat = db.query(Category).filter(Category.name == cat_info["name"]).first()
            if not cat:
                cat = Category(name=cat_info["name"], description=cat_info["description"])
                db.add(cat)
                db.flush()
                print(f"Kategori eklendi: {cat.name}")
            category_map[cat.name] = cat.id

        db.commit()

        # 3. Sanat Eserleri (Artworks)
        artworks_data = [
            {
                "title": "Davud (David)",
                "artist": "Michelangelo Buonarroti",
                "year": 1504,
                "image_url": "https://images.unsplash.com/photo-1582561424760-0321d75e81fa?auto=format&fit=crop&w=1200&q=80",
                "description": "Rönesans heykel sanatının zirvesi kabul edilen 5.17 metrelik mermer heykel. Golyat'a karşı mücadeleye hazırlanan Davud'un kararlılığını ve ideal insan anatomisini yansıtır.",
                "category_name": "Heykel Sanatı"
            },
            {
                "title": "Adem'in Yaratılışı",
                "artist": "Michelangelo Buonarroti",
                "year": 1512,
                "image_url": "https://images.unsplash.com/photo-1579783902614-a3fb3927b675?auto=format&fit=crop&w=1200&q=80",
                "description": "Sistine Şapeli tavanındaki en ünlü fresk sahnesi. Tanrı'nın parmağının Adem'in parmağına neredeyse dokunarak insana yaşam kıvılcımını verdiği anı tasvir eder.",
                "category_name": "Fresk & Tavan Resmi"
            },
            {
                "title": "Pietà",
                "artist": "Michelangelo Buonarroti",
                "year": 1499,
                "image_url": "https://images.unsplash.com/photo-1577083552431-6e5fd01aa342?auto=format&fit=crop&w=1200&q=80",
                "description": "Roma'daki Aziz Petrus Bazilikası'nda yer alan, çarmıhtan indirilen İsa'nın kucağındaki Meryem Ana'yı derin bir sükunet ve zarafetle tasvir eden mermer başyapıt.",
                "category_name": "Heykel Sanatı"
            },
            {
                "title": "Mona Lisa",
                "artist": "Leonardo da Vinci",
                "year": 1503,
                "image_url": "https://images.unsplash.com/photo-1561214115-f2f134cc4912?auto=format&fit=crop&w=1200&q=80",
                "description": "Louvre Müzesi'nin kalbi; sfumato tekniğinin inceliği, gizemli gülümsemesi ve arka plandaki atmosferik derinliğiyle dünyanın en tanınan tablosu.",
                "category_name": "Yüksek Rönesans"
            },
            {
                "title": "Son Akşam Yemeği",
                "artist": "Leonardo da Vinci",
                "year": 1498,
                "image_url": "https://images.unsplash.com/photo-1580136579312-94651dfd596d?auto=format&fit=crop&w=1200&q=80",
                "description": "Milano'daki Santa Maria delle Grazie manastırının duvarında yer alan anıtsal duvar resmi. İsa'nın havarilerine aralarından birinin kendisine ihanet edeceğini söylediği dramatik anı betimler.",
                "category_name": "Yüksek Rönesans"
            },
            {
                "title": "Atina Okulu",
                "artist": "Raffaello Sanzio",
                "year": 1511,
                "image_url": "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=1200&q=80",
                "description": "Vatikan Apostol Sarayı'ndaki fresk. Antik Yunan felsefesinin Platon, Aristoteles ve Sokrates gibi büyük düşünürlerini Rönesans mimarisi içinde bir araya getirir.",
                "category_name": "Fresk & Tavan Resmi"
            },
            {
                "title": "Aziz Matta'ya Çağrı",
                "artist": "Caravaggio",
                "year": 1600,
                "image_url": "https://images.unsplash.com/photo-1578328819058-b69f3a3b0f6b?auto=format&fit=crop&w=1200&q=80",
                "description": "Barok döneminin devrimci eseri. Dramatik chiaroscuro tekniğiyle pencereden giren ışık hüzmesinin vergi memuru Levi'yi aydınlattığı ilahi çağrı anı.",
                "category_name": "Barok"
            },
            {
                "title": "Kıyamet Günü (The Last Judgment)",
                "artist": "Michelangelo Buonarroti",
                "year": 1541,
                "image_url": "https://images.unsplash.com/photo-1579783901586-7880cb4cd974?auto=format&fit=crop&w=1200&q=80",
                "description": "Sistine Şapeli'nin sunak duvarındaki anıtsal fresk. İsa'nın ikinci gelişinde ruhların yargılanmasını dinamik, güçlü ve sarsıcı figürlerle yansıtır.",
                "category_name": "Fresk & Tavan Resmi"
            }
        ]

        for art in artworks_data:
            existing = db.query(Artwork).filter(Artwork.title == art["title"]).first()
            if existing:
                existing.image_url = art["image_url"]
                existing.artist = art["artist"]
                existing.year = art["year"]
                existing.description = art["description"]
                existing.category_id = category_map[art["category_name"]]
                print(f"Eser güncellendi: {art['title']}")
            else:
                cat_id = category_map[art["category_name"]]
                artwork = Artwork(
                    title=art["title"],
                    artist=art["artist"],
                    year=art["year"],
                    image_url=art["image_url"],
                    description=art["description"],
                    category_id=cat_id,
                )
                db.add(artwork)
                print(f"Eser eklendi: {art['title']} - {art['artist']}")

        db.commit()
        print("Tohumlama tamamlandı! Veritabanı zengin eser içeriğiyle hazır.")

    except Exception as e:
        db.rollback()
        print(f"Hata oluştu: {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
