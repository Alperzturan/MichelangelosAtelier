"""
Michelangelo's Atelier - Veritabanı Tohumlama (Seed) Betiği
Klasik ve modern dönemlere ait 8 kategori, 65 doğrulanmış başyapıt ve örnek kullanıcılar ekler.
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

        # 2. Kategoriler (Sanat Akımları)
        categories_data = [
            {
                "name": "Yüksek Rönesans",
                "description": "15. yüzyıl sonu ile 16. yüzyıl başı İtalyan sanatının zirve dönemi; kusursuz anatomi, kompozisyon ve perspektif uyumu.",
            },
            {
                "name": "Erken Rönesans",
                "description": "15. yüzyıl Floransa ve İtalya'sında perspektif, doğa gözlemi ve hümanizmin temellerini atan öncü dönem.",
            },
            {
                "name": "Kuzey Rönesansı",
                "description": "Flaman ve Alman ustaların yağlıboya ustalığı, ince detay işçiliği ve günlük yaşam gözlemleriyle öne çıkan akımı.",
            },
            {
                "name": "Heykel Sanatı",
                "description": "Mermer ve bronzun usta ellerde hayat bulduğu üç boyutlu klasik ve modern başyapıtlar.",
            },
            {
                "name": "Barok",
                "description": "17. yüzyıl Avrupa'sında ortaya çıkan, dramatik ışık-gölge (chiaroscuro) kullanımı ve yoğun duygusal anlatımıyla öne çıkan sanat akımı.",
            },
            {
                "name": "Fresk & Tavan Resmi",
                "description": "Yaş sıva üzerine yapılan anıtsal duvar ve tavan süsleme resimleri.",
            },
            {
                "name": "Romantizm & Neoklasisizm",
                "description": "18. ve 19. yüzyıllarda akılcılık ile coşkulu duygu, tarih ve doğanın yüceliğini buluşturan akımlar.",
            },
            {
                "name": "Empresyonizm & Post-Empresyonizm",
                "description": "Işığın anlık etkilerini, özgür fırça darbelerini ve renk kuramını modern sanata taşıyan devrimci akımlar.",
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

        # 3. Sanat Eserleri (Artworks - 65 doğrulanmış başyapıt)
        artworks_data = [
            {
                        "title": "Mona Lisa",
                        "artist": "Leonardo da Vinci",
                        "year": 1503,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/330px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Louvre Müzesi'nin kalbi; sfumato tekniğinin inceliği, gizemli gülümsemesi ve atmosferik derinliğiyle dünya sanat tarihinin en tanınan tablosu.",
                        "category_name": "Yüksek Rönesans"
            },
            {
                        "title": "Son Akşam Yemeği",
                        "artist": "Leonardo da Vinci",
                        "year": 1498,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/48/The_Last_Supper_-_Leonardo_Da_Vinci_-_High_Resolution_32x16.jpg/330px-The_Last_Supper_-_Leonardo_Da_Vinci_-_High_Resolution_32x16.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Milano'daki Santa Maria delle Grazie manastırının duvarında yer alan, İsa'nın havarilerine ihanet haberini verdiği anı betimleyen anıtsal eser.",
                        "category_name": "Fresk & Tavan Resmi"
            },
            {
                        "title": "Vitruvius Adamı",
                        "artist": "Leonardo da Vinci",
                        "year": 1490,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/22/Da_Vinci_Vitruve_Luc_Viatour.jpg/330px-Da_Vinci_Vitruve_Luc_Viatour.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Antik Romalı mimar Vitruvius'un oran kuramından esinlenerek insan anatomisinin ideal geometrik ölçülerini gösteren ünlü çizim.",
                        "category_name": "Yüksek Rönesans"
            },
            {
                        "title": "Kakımlı Kadın",
                        "artist": "Leonardo da Vinci",
                        "year": 1489,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bf/Lady_with_an_Ermine_-_Leonardo_da_Vinci_%28adjusted_levels%29.jpg/330px-Lady_with_an_Ermine_-_Leonardo_da_Vinci_%28adjusted_levels%29.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Cecilia Gallerani'nin zarif duruşunu ve elindeki kakımı psikolojik derinlik ve ışık ustalığıyla yansıtan Rönesans portresi.",
                        "category_name": "Yüksek Rönesans"
            },
            {
                        "title": "Davud (David)",
                        "artist": "Michelangelo Buonarroti",
                        "year": 1504,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/80/Michelangelo%27s_David_-_right_view_2.jpg/330px-Michelangelo%27s_David_-_right_view_2.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Floransa'da bulunan 5.17 metrelik mermer heykel; Golyat'a karşı mücadeleye hazırlanan Davud'un kararlılığını ve ideal insan anatomisini yansıtır.",
                        "category_name": "Heykel Sanatı"
            },
            {
                        "title": "Pietà",
                        "artist": "Michelangelo Buonarroti",
                        "year": 1499,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/65/Pieta_de_Michelangelo_-_Vaticano.jpg/330px-Pieta_de_Michelangelo_-_Vaticano.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Vatikan Aziz Petrus Bazilikası'nda yer alan, çarmıhtan indirilen İsa'yı kucağında tutan Meryem Ana'yı derin bir sükunetle betimleyen mermer başyapıt.",
                        "category_name": "Heykel Sanatı"
            },
            {
                        "title": "Adem'in Yaratılışı",
                        "artist": "Michelangelo Buonarroti",
                        "year": 1512,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5b/Michelangelo_-_Creation_of_Adam_%28cropped%29.jpg/330px-Michelangelo_-_Creation_of_Adam_%28cropped%29.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Sistine Şapeli tavanındaki en ünlü fresk sahnesi; Tanrı'nın parmağının Adem'in parmağına yaşam kıvılcımını verdiği anı tasvir eder.",
                        "category_name": "Fresk & Tavan Resmi"
            },
            {
                        "title": "Kıyamet Günü (The Last Judgment)",
                        "artist": "Michelangelo Buonarroti",
                        "year": 1541,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/18/Last_Judgement_%28Michelangelo%29.jpg/330px-Last_Judgement_%28Michelangelo%29.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Sistine Şapeli'nin sunak duvarını kaplayan, İsa'nın ikinci gelişinde ruhların yargılanmasını anıtsal figürlerle anlatan dev fresk.",
                        "category_name": "Fresk & Tavan Resmi"
            },
            {
                        "title": "Musa Heykeli",
                        "artist": "Michelangelo Buonarroti",
                        "year": 1515,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/59/Michelangelo%27s_Moses_%28Rome%29.jpg/330px-Michelangelo%27s_Moses_%28Rome%29.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Roma'daki San Pietro in Vincoli kilisesinde Papa II. Julius'un anıt mezarı için yontulan, güçlü kas yapısı ve ifadeci bakışıyla ünlü mermer heykel.",
                        "category_name": "Heykel Sanatı"
            },
            {
                        "title": "Atina Okulu",
                        "artist": "Raffaello Sanzio",
                        "year": 1511,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/49/%22The_School_of_Athens%22_by_Raffaello_Sanzio_da_Urbino.jpg/330px-%22The_School_of_Athens%22_by_Raffaello_Sanzio_da_Urbino.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Vatikan Odaları'ndaki fresk; Platon, Aristoteles ve Sokrates gibi Antik Yunan düşünürlerini kusursuz Rönesans perspektifi içinde buluşturur.",
                        "category_name": "Fresk & Tavan Resmi"
            },
            {
                        "title": "Sistine Madonnası",
                        "artist": "Raffaello Sanzio",
                        "year": 1512,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/7a/RAFAEL_-_Madonna_Sixtina_%28Gem%C3%A4ldegalerie_Alter_Meister%2C_Dresden%2C_1513-14._%C3%93leo_sobre_lienzo%2C_265_x_196_cm%29.jpg/330px-RAFAEL_-_Madonna_Sixtina_%28Gem%C3%A4ldegalerie_Alter_Meister%2C_Dresden%2C_1513-14._%C3%93leo_sobre_lienzo%2C_265_x_196_cm%29.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Bulutlar üzerinde beliren Meryem ve Çocuk İsa'yı, alt kısımdaki ünlü düşünceli iki melek figürüyle birlikte betimleyen sunak resmi.",
                        "category_name": "Yüksek Rönesans"
            },
            {
                        "title": "La Fornarina",
                        "artist": "Raffaello Sanzio",
                        "year": 1519,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8d/Raffaello_Sanzio_-_La_Fornarina_%28ca._1519-1520%29.jpg/330px-Raffaello_Sanzio_-_La_Fornarina_%28ca._1519-1520%29.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Raffaello'nun geç dönem başyapıtlarından biri olan, sıcak renk geçişleri ve zarif ışık kullanımıyla öne çıkan kadın portresi.",
                        "category_name": "Yüksek Rönesans"
            },
            {
                        "title": "Urbino Venüsü",
                        "artist": "Titian",
                        "year": 1538,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bb/Tiziano_-_Venere_di_Urbino_-_Google_Art_Project.jpg/330px-Tiziano_-_Venere_di_Urbino_-_Google_Art_Project.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Venedik Rönesansı'nın renk ve doku ustalığını sergileyen, iç mekân derinliği ve sıcak tonlarıyla klasikleşmiş yağlıboya tablo.",
                        "category_name": "Yüksek Rönesans"
            },
            {
                        "title": "Meryem'in Göğe Yükselişi",
                        "artist": "Titian",
                        "year": 1518,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9e/Tizian_041.jpg/330px-Tizian_041.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Venedik'teki Frari Bazilikası için yapılan, altın gökyüzü ve dinamik renk kompozisyonuyla Yüksek Rönesans'ın dönüm noktalarından biri.",
                        "category_name": "Yüksek Rönesans"
            },
            {
                        "title": "Baküs ve Ariadne",
                        "artist": "Titian",
                        "year": 1523,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/be/Titian_Bacchus_and_Ariadne.jpg/330px-Titian_Bacchus_and_Ariadne.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Mitolojik bir karşılaşmayı canlı ultramarin mavisi ve hareketli figürlerle ölümsüzleştiren Venedik okulu başyapıtı.",
                        "category_name": "Yüksek Rönesans"
            },
            {
                        "title": "Venüs'ün Doğuşu",
                        "artist": "Sandro Botticelli",
                        "year": 1485,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0b/Sandro_Botticelli_-_La_nascita_di_Venere_-_Google_Art_Project_-_edited.jpg/330px-Sandro_Botticelli_-_La_nascita_di_Venere_-_Google_Art_Project_-_edited.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Deniz kabuğu üzerinde kıyıya ulaşan aşk tanrıçası Venüs'ü zarif çizgiler ve mitolojik şiirsellikle betimleyen Floransa başyapıtı.",
                        "category_name": "Erken Rönesans"
            },
            {
                        "title": "İlkbahar (Primavera)",
                        "artist": "Sandro Botticelli",
                        "year": 1482,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3c/Botticelli-primavera.jpg/330px-Botticelli-primavera.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Çiçeklerle bezeli portakal korusunda Venüs ve mitolojik figürlerin dansını alegorik bir zarafetle anlatan Erken Rönesans tablosu.",
                        "category_name": "Erken Rönesans"
            },
            {
                        "title": "Müjde (Annunciation)",
                        "artist": "Fra Angelico",
                        "year": 1442,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bc/Fra_Angelico_-_Annunciation.jpg/330px-Fra_Angelico_-_Annunciation.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Floransa San Marco Manastırı freski; sade mimari perspektifi ve dingin renkleriyle Erken Rönesans'ın manevi atmosferini yansıtır.",
                        "category_name": "Erken Rönesans"
            },
            {
                        "title": "Cennetten Kovuluş",
                        "artist": "Masaccio",
                        "year": 1425,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/37/Masaccio-TheExpulsionOfAdamAndEveFromEden-Restoration.jpg/330px-Masaccio-TheExpulsionOfAdamAndEveFromEden-Restoration.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Floransa Brancacci Şapeli'nde yer alan, insan duygusunu ve hacimli ışık-gölgeyi ilk kez gerçekçi biçimde işleyen öncü fresk.",
                        "category_name": "Fresk & Tavan Resmi"
            },
            {
                        "title": "San Romano Muharebesi",
                        "artist": "Paolo Uccello",
                        "year": 1438,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e3/Uccello_%E2%80%94_the_Battle_of_San_Romano.jpg/330px-Uccello_%E2%80%94_the_Battle_of_San_Romano.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Floransa ve Siena orduları arasındaki savaşı geometrik çizgisel perspektif denemeleriyle kurgulayan üçlü pano serisi.",
                        "category_name": "Erken Rönesans"
            },
            {
                        "title": "İsa'nın Kırbaçlanması",
                        "artist": "Piero della Francesca",
                        "year": 1460,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2b/Piero_della_Francesca_-_Flagelaci%C3%B3n_de_Cristo%2C_1468-1470_%28Galleria_Nazionale_delle_Marche%2C_Urbino%29.png/330px-Piero_della_Francesca_-_Flagelaci%C3%B3n_de_Cristo%2C_1468-1470_%28Galleria_Nazionale_delle_Marche%2C_Urbino%29.png?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Matematiksel perspektif uyumu ve gizemli figür düzeniyle sanat tarihçilerinin en çok incelediği Erken Rönesans eserlerinden biri.",
                        "category_name": "Erken Rönesans"
            },
            {
                        "title": "Bronz Davud",
                        "artist": "Donatello",
                        "year": 1440,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f7/Donatello%2C_David%2C_bronze%2C_1435-40%2C_Florence%2C_Bargello%2C_detail.jpg/330px-Donatello%2C_David%2C_bronze%2C_1435-40%2C_Florence%2C_Bargello%2C_detail.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Antik çağdan bu yana yapılan ilk serbest duran çıplak bronz heykel; Erken Rönesans heykel sanatının dönüm noktasıdır.",
                        "category_name": "Heykel Sanatı"
            },
            {
                        "title": "Ölü İsa'ya Ağıt",
                        "artist": "Andrea Mantegna",
                        "year": 1480,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f4/The_dead_Christ_and_three_mourners%2C_by_Andrea_Mantegna.jpg/330px-The_dead_Christ_and_three_mourners%2C_by_Andrea_Mantegna.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Çarpıcı kısaltım (foreshortening) perspektifiyle izleyiciyi doğrudan sahnenin içine çeken dramatik Rönesans tablosu.",
                        "category_name": "Erken Rönesans"
            },
            {
                        "title": "Arnolfini'nin Evlenmesi",
                        "artist": "Jan van Eyck",
                        "year": 1434,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/53/The_Arnolfini_portrait_%281434%29.jpg/330px-The_Arnolfini_portrait_%281434%29.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Arka duvardaki dışbükey aynadaki yansımaya kadar olağanüstü ayrıntı zenginliği ve yağlıboya parlaklığı sunan Flaman başyapıtı.",
                        "category_name": "Kuzey Rönesansı"
            },
            {
                        "title": "Ghent Mihrap Panosu",
                        "artist": "Jan van Eyck",
                        "year": 1432,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/50/Ghent_Altarpiece_Google_Art_Project.jpg/330px-Ghent_Altarpiece_Google_Art_Project.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Yağlıboya tekniğinin tüm inceliklerini ortaya koyan, çok panelli anıtsal Kuzey Rönesansı sunak eseri.",
                        "category_name": "Kuzey Rönesansı"
            },
            {
                        "title": "Dünyevi Zevkler Bahçesi",
                        "artist": "Hieronymus Bosch",
                        "year": 1510,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/96/The_Garden_of_earthly_delights.jpg/330px-The_Garden_of_earthly_delights.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Cennet, dünya ve cehennemi gerçeküstü ve sembolik figürlerle üç kanatta anlatan gizemli triptik.",
                        "category_name": "Kuzey Rönesansı"
            },
            {
                        "title": "Karda Avcılar",
                        "artist": "Pieter Bruegel (Baba)",
                        "year": 1565,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d8/Pieter_Bruegel_the_Elder_-_Hunters_in_the_Snow_%28Winter%29_-_Google_Art_Project.jpg/330px-Pieter_Bruegel_the_Elder_-_Hunters_in_the_Snow_%28Winter%29_-_Google_Art_Project.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Kış manzarasında köye dönen avcıları ve donmuş gölde kayan köylüleri geniş bir kuşbakışı kompozisyonla resmeden Flaman şaheseri.",
                        "category_name": "Kuzey Rönesansı"
            },
            {
                        "title": "Babil Kulesi",
                        "artist": "Pieter Bruegel (Baba)",
                        "year": 1563,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/fc/Pieter_Bruegel_the_Elder_-_The_Tower_of_Babel_%28Vienna%29_-_Google_Art_Project_-_edited.jpg/330px-Pieter_Bruegel_the_Elder_-_The_Tower_of_Babel_%28Vienna%29_-_Google_Art_Project_-_edited.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "İnsan kibrini ve devasa mimari ayrıntıları yüzlerce küçük figür eşliğinde anlatan ikonik tablo.",
                        "category_name": "Kuzey Rönesansı"
            },
            {
                        "title": "Melencolia I",
                        "artist": "Albrecht Dürer",
                        "year": 1514,
                        "image_url": "https://upload.wikimedia.org/wikipedia/commons/7/7a/Albrecht_D%C3%BCrer_-_Melencolia_I_-_Google_Art_Project_%28_AGDdr3EHmNGyA%29.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail_unscaled",
                        "description": "Matematik, geometri ve insan yaratıcılığının sınırlarını simgeleyen, bakır gravür tekniğinin zirvesi kabul edilen eser.",
                        "category_name": "Kuzey Rönesansı"
            },
            {
                        "title": "Elçiler (The Ambassadors)",
                        "artist": "Hans Holbein (Genç)",
                        "year": 1533,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/88/Hans_Holbein_the_Younger_-_The_Ambassadors_-_Google_Art_Project.jpg/330px-Hans_Holbein_the_Younger_-_The_Ambassadors_-_Google_Art_Project.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Ön plandaki anamorfik kafatası detayı ve dönemin bilimsel aletleriyle dolu zengin Rönesans çift portresi.",
                        "category_name": "Kuzey Rönesansı"
            },
            {
                        "title": "Aziz Matta'ya Çağrı",
                        "artist": "Caravaggio",
                        "year": 1600,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/59/Caravaggio_%E2%80%94_The_Calling_of_Saint_Matthew.jpg/330px-Caravaggio_%E2%80%94_The_Calling_of_Saint_Matthew.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Dramatik chiaroscuro (ışık-gölge) tekniğiyle pencereden süzülen ilahi ışığın vergi memuru Levi'yi aydınlattığı Barok dönüm noktası.",
                        "category_name": "Barok"
            },
            {
                        "title": "Yudit ve Holofernes",
                        "artist": "Caravaggio",
                        "year": 1599,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/df/Caravaggio_-_Giuditta_e_Oloferne_%28ca._1599%29.jpg/330px-Caravaggio_-_Giuditta_e_Oloferne_%28ca._1599%29.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Tenebrizm tekniğinin çarpıcı gerçekçiliğiyle İncil öyküsünü yoğun gerilim içinde sunan Barok başyapıt.",
                        "category_name": "Barok"
            },
            {
                        "title": "Emmaus'ta Akşam Yemeği",
                        "artist": "Caravaggio",
                        "year": 1601,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4d/1602-3_Caravaggio%2CSupper_at_Emmaus_National_Gallery%2C_London.jpg/330px-1602-3_Caravaggio%2CSupper_at_Emmaus_National_Gallery%2C_London.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Masadaki meyve sepetinden uzanan ellere kadar üç boyutlu derinlik hissi veren dramatik Caravaggio tablosu.",
                        "category_name": "Barok"
            },
            {
                        "title": "Gece Devriyesi",
                        "artist": "Rembrandt van Rijn",
                        "year": 1642,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3a/La_ronda_de_noche%2C_por_Rembrandt_van_Rijn.jpg/330px-La_ronda_de_noche%2C_por_Rembrandt_van_Rijn.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Amsterdam şehir muhafızlarını durağan bir grup portresi yerine hareket, ışık ve gölge içinde yakalayan dev Barok şaheser.",
                        "category_name": "Barok"
            },
            {
                        "title": "Dr. Nicolaes Tulp'un Anatomi Dersi",
                        "artist": "Rembrandt van Rijn",
                        "year": 1632,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4d/Rembrandt_-_The_Anatomy_Lesson_of_Dr_Nicolaes_Tulp.jpg/330px-Rembrandt_-_The_Anatomy_Lesson_of_Dr_Nicolaes_Tulp.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Genç Rembrandt'ı üne kavuşturan, tıp öğrencilerinin dikkatini ve dramatik ışık odağını ustalıkla işleyen tablo.",
                        "category_name": "Barok"
            },
            {
                        "title": "Savurgan Oğlun Dönüşü",
                        "artist": "Rembrandt van Rijn",
                        "year": 1669,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/93/Rembrandt_Harmensz_van_Rijn_-_Return_of_the_Prodigal_Son_-_Google_Art_Project.jpg/330px-Rembrandt_Harmensz_van_Rijn_-_Return_of_the_Prodigal_Son_-_Google_Art_Project.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Rembrandt'ın son yıllarında sıcak toprak tonları ve derin şefkat duygusuyla tamamladığı ruhani başyapıt.",
                        "category_name": "Barok"
            },
            {
                        "title": "İnci Küpeli Kız",
                        "artist": "Johannes Vermeer",
                        "year": 1665,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0f/1665_Girl_with_a_Pearl_Earring.jpg/330px-1665_Girl_with_a_Pearl_Earring.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "'Kuzey'in Mona Lisa'sı' olarak anılan, karanlık fon önünde inci küpenin parıltısı ve bakışındaki gizemle ünlü tronie.",
                        "category_name": "Barok"
            },
            {
                        "title": "Sütçü Kız",
                        "artist": "Johannes Vermeer",
                        "year": 1658,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/6e/Johannes_Vermeer_-_Het_melkmeisje_-_Google_Art_Project.png/330px-Johannes_Vermeer_-_Het_melkmeisje_-_Google_Art_Project.png?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Pencereden süzülen doğal gün ışığının ekmek ve süt testisi üzerindeki dokuları aydınlattığı huzurlu Hollanda Altın Çağı eseri.",
                        "category_name": "Barok"
            },
            {
                        "title": "Astronom",
                        "artist": "Johannes Vermeer",
                        "year": 1668,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e4/Johannes_Vermeer_-_The_Astronomer_-_1668.jpg/330px-Johannes_Vermeer_-_The_Astronomer_-_1668.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Bilimsel merakı ve gök küresini inceleyen bilgini Vermeer'in karakteristik dingin ışığıyla resmeden tablo.",
                        "category_name": "Barok"
            },
            {
                        "title": "Nedimeler (Las Meninas)",
                        "artist": "Diego Velázquez",
                        "year": 1656,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/31/Las_Meninas%2C_by_Diego_Vel%C3%A1zquez%2C_from_Prado_in_Google_Earth.jpg/330px-Las_Meninas%2C_by_Diego_Vel%C3%A1zquez%2C_from_Prado_in_Google_Earth.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "İspanyol Kraliyet ailesini, ressamın kendisini ve arka aynadaki yansımayı iç içe geçiren perspektif ve gerçeklik oyunu.",
                        "category_name": "Barok"
            },
            {
                        "title": "Breda'nın Teslimi",
                        "artist": "Diego Velázquez",
                        "year": 1635,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8e/Velazquez-The_Surrender_of_Breda.jpg/330px-Velazquez-The_Surrender_of_Breda.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Savaşın galibi ve mağlubu arasındaki saygıyı mızraklar ormanı önünde betimleyen tarihi Barok kompozisyon.",
                        "category_name": "Barok"
            },
            {
                        "title": "Azize Teresa'nın Vecdi",
                        "artist": "Gian Lorenzo Bernini",
                        "year": 1652,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1a/Ecstasy_of_St._Teresa_HDR.jpg/330px-Ecstasy_of_St._Teresa_HDR.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Roma'daki Cornaro Şapeli'nde beyaz mermer, altın ışınlar ve doğal ışıkla tiyatral bir bütünlük oluşturan Barok heykel şaheseri.",
                        "category_name": "Heykel Sanatı"
            },
            {
                        "title": "Apollon ve Daphne",
                        "artist": "Gian Lorenzo Bernini",
                        "year": 1625,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/ab/Apollo_and_Daphne_%28Bernini%29_%28cropped%29.jpg/330px-Apollo_and_Daphne_%28Bernini%29_%28cropped%29.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Daphne'nin defne ağacına dönüşüm anını mermerde yaprak ve dal dokularına dönüştüren inanılmaz virtüözite.",
                        "category_name": "Heykel Sanatı"
            },
            {
                        "title": "Proserpina'nın Kaçırılışı",
                        "artist": "Gian Lorenzo Bernini",
                        "year": 1622,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/36/Rape_of_Prosepina_September_2015-3a.jpg/330px-Rape_of_Prosepina_September_2015-3a.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Pluto'nun parmaklarının mermer tene bastırdığı hissi verecek kadar gerçekçi yontulmuş Barok heykel.",
                        "category_name": "Heykel Sanatı"
            },
            {
                        "title": "Aşk Tanrısının Öpücüğüyle Canlanan Psyche",
                        "artist": "Antonio Canova",
                        "year": 1793,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/ef/0_Psych%C3%A9_ranim%C3%A9e_par_le_baiser_de_l%27Amour_-_Canova_-_Louvre_1.JPG/330px-0_Psych%C3%A9_ranim%C3%A9e_par_le_baiser_de_l%27Amour_-_Canova_-_Louvre_1.JPG?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Neoklasik heykelin en zarif örneği; mermerin yumuşaklığı ve kanatların dengesiyle ölümsüz bir sevgi anı.",
                        "category_name": "Heykel Sanatı"
            },
            {
                        "title": "Düşünen Adam",
                        "artist": "Auguste Rodin",
                        "year": 1904,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a4/Le_Penseur_by_Rodin_%28Kunsthalle_Bielefeld%29_2014-04-10.JPG/330px-Le_Penseur_by_Rodin_%28Kunsthalle_Bielefeld%29_2014-04-10.JPG?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Cehennem Kapıları anıtının parçası olarak doğan, insan zihninin derin tefekkürünü güçlü bronz kaslarla simgeleyen modern klasik.",
                        "category_name": "Heykel Sanatı"
            },
            {
                        "title": "Öpücük (The Kiss)",
                        "artist": "Auguste Rodin",
                        "year": 1882,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d1/Rodin_-_Le_Baiser_06.jpg/330px-Rodin_-_Le_Baiser_06.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Dante'nin İlahi Komedya'sındaki Paolo ve Francesca'dan esinlenen, pürüzlü mermer kaide üzerinde yükselen tutkulu heykel.",
                        "category_name": "Heykel Sanatı"
            },
            {
                        "title": "Milo Venüsü",
                        "artist": "Antakyalı Aleksandros",
                        "year": -130,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c2/Front_views_of_the_Venus_de_Milo.jpg/330px-Front_views_of_the_Venus_de_Milo.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Helenistik dönemin en ünlü mermer heykellerinden; oran uyumu ve kıvrımlı giysi işçiliğiyle klasik güzellik idealini temsil eder.",
                        "category_name": "Heykel Sanatı"
            },
            {
                        "title": "Semadirek Kanatlı Zaferi",
                        "artist": "Bilinmeyen Helenistik Usta",
                        "year": -190,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bf/Victoire_de_Samothrace_-_Musee_du_Louvre_-_20190812.jpg/330px-Victoire_de_Samothrace_-_Musee_du_Louvre_-_20190812.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Louvre merdivenlerinin başında yükselen, rüzgara karşı açılmış kanatları ve ıslak kumaş kıvrımlarıyla nefes kesen antik heykel.",
                        "category_name": "Heykel Sanatı"
            },
            {
                        "title": "Horatiusların Yemini",
                        "artist": "Jacques-Louis David",
                        "year": 1784,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bd/Le_Serment_des_Horaces_-_Jacques-Louis_David_-_Mus%C3%A9e_du_Louvre_Peintures_INV_3692_%3B_MR_1432.jpg/330px-Le_Serment_des_Horaces_-_Jacques-Louis_David_-_Mus%C3%A9e_du_Louvre_Peintures_INV_3692_%3B_MR_1432.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Roma cumhuriyet erdemlerini, keskin geometrik düzeni ve kararlı duruşlarıyla Neoklasisizm akımının manifestosu.",
                        "category_name": "Romantizm & Neoklasisizm"
            },
            {
                        "title": "Marat'nın Ölümü",
                        "artist": "Jacques-Louis David",
                        "year": 1793,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/aa/Death_of_Marat_by_David.jpg/330px-Death_of_Marat_by_David.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Fransız Devrimi'nin en çarpıcı imgelerinden biri; sade arka plan ve dingin ışıkla trajediyi anıtsallaştırır.",
                        "category_name": "Romantizm & Neoklasisizm"
            },
            {
                        "title": "Halka Yol Gösteren Özgürlük",
                        "artist": "Eugène Delacroix",
                        "year": 1830,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/02/La_Libert%C3%A9_guidant_le_peuple_-_Eug%C3%A8ne_Delacroix_-_Mus%C3%A9e_du_Louvre_Peintures_RF_129_-_apr%C3%A8s_restauration_2024.jpg/330px-La_Libert%C3%A9_guidant_le_peuple_-_Eug%C3%A8ne_Delacroix_-_Mus%C3%A9e_du_Louvre_Peintures_RF_129_-_apr%C3%A8s_restauration_2024.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "1830 Temmuz Devrimi'ni üç renkli bayrağı taşıyan Marianne figürüyle coşkulu bir Romantizm şaheserine dönüştüren tablo.",
                        "category_name": "Romantizm & Neoklasisizm"
            },
            {
                        "title": "Medusa'nın Salı",
                        "artist": "Théodore Géricault",
                        "year": 1819,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/15/JEAN_LOUIS_TH%C3%89ODORE_G%C3%89RICAULT_-_La_Balsa_de_la_Medusa_%28Museo_del_Louvre%2C_1818-19%29.jpg/330px-JEAN_LOUIS_TH%C3%89ODORE_G%C3%89RICAULT_-_La_Balsa_de_la_Medusa_%28Museo_del_Louvre%2C_1818-19%29.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Denizdeki hayatta kalma mücadelesini piramidal kompozisyon ve dramatik dalgalarla anlatan Fransız Romantizmi öncüsü.",
                        "category_name": "Romantizm & Neoklasisizm"
            },
            {
                        "title": "3 Mayıs 1808",
                        "artist": "Francisco Goya",
                        "year": 1814,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/fd/El_Tres_de_Mayo%2C_by_Francisco_de_Goya%2C_from_Prado_thin_black_margin.jpg/330px-El_Tres_de_Mayo%2C_by_Francisco_de_Goya%2C_from_Prado_thin_black_margin.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Savaşın acımasızlığını beyaz gömlekli figür üzerindeki fener ışığıyla haykıran modern savaş karşıtı resim öncüsü.",
                        "category_name": "Romantizm & Neoklasisizm"
            },
            {
                        "title": "Oğlunu Yiyen Satürn",
                        "artist": "Francisco Goya",
                        "year": 1823,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/82/Francisco_de_Goya%2C_Saturno_devorando_a_su_hijo_%281819-1823%29.jpg/330px-Francisco_de_Goya%2C_Saturno_devorando_a_su_hijo_%281819-1823%29.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Goya'nın 'Kara Resimler' serisinden, insanın içindeki karanlığı ve zamanın yıkıcılığını sarsıcı biçimde yansıtan eser.",
                        "category_name": "Romantizm & Neoklasisizm"
            },
            {
                        "title": "Savaşan Temeraire",
                        "artist": "J. M. W. Turner",
                        "year": 1839,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/30/The_Fighting_Temeraire%2C_JMW_Turner%2C_National_Gallery.jpg/330px-The_Fighting_Temeraire%2C_JMW_Turner%2C_National_Gallery.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Eski yelkenli savaş gemisinin son yolculuğunu ateş kırmızısı ve altın tonlu bir gün batımı eşliğinde anlatan başyapıt.",
                        "category_name": "Romantizm & Neoklasisizm"
            },
            {
                        "title": "Bulutların Üzerinde Yolculuk",
                        "artist": "Caspar David Friedrich",
                        "year": 1818,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/af/Caspar_David_Friedrich_-_Wanderer_above_the_Sea_of_Fog.jpeg/330px-Caspar_David_Friedrich_-_Wanderer_above_the_Sea_of_Fog.jpeg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Sırtı dönük bir gezginin sisli dağ zirvelerine bakışıyla doğanın yüceliğini (sublime) simgeleyen Alman Romantizmi ikonu.",
                        "category_name": "Romantizm & Neoklasisizm"
            },
            {
                        "title": "İzlenim: Gün Doğumu",
                        "artist": "Claude Monet",
                        "year": 1872,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/59/Monet_-_Impression%2C_Sunrise.jpg/330px-Monet_-_Impression%2C_Sunrise.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Empresyonizm (İzlenimcilik) akımına adını veren, Le Havre limanındaki puslu sabah ışığını hızlı fırça darbeleriyle yakalayan eser.",
                        "category_name": "Empresyonizm & Post-Empresyonizm"
            },
            {
                        "title": "Nilüferler (Water Lilies)",
                        "artist": "Claude Monet",
                        "year": 1916,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4b/Reflections_of_Clouds_on_the_Water-Lily_Pond.jpg/330px-Reflections_of_Clouds_on_the_Water-Lily_Pond.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Monet'nin Giverny bahçesindeki su yüzeyi yansımalarını ve renk armonisini soyuta yaklaşan bir duyarlılıkla işlediği seri.",
                        "category_name": "Empresyonizm & Post-Empresyonizm"
            },
            {
                        "title": "Moulin de la Galette'te Balo",
                        "artist": "Pierre-Auguste Renoir",
                        "year": 1876,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/6f/Renoir%2C_Pierre-Auguste_-_Dance_at_Le_Moulin_de_la_Galette%2C_1876.jpg/330px-Renoir%2C_Pierre-Auguste_-_Dance_at_Le_Moulin_de_la_Galette%2C_1876.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Ağaç yaprakları arasından süzülen güneş lekelerinin Parisli kalabalığın neşesiyle buluştuğu ikonik Empresyonist tablo.",
                        "category_name": "Empresyonizm & Post-Empresyonizm"
            },
            {
                        "title": "Yıldızlı Gece",
                        "artist": "Vincent van Gogh",
                        "year": 1889,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/ea/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/330px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Saint-Rémy'deki pencereden görülen gece gökyüzünü dönen yıldız girdapları ve güçlü impasto fırça darbeleriyle ölümsüzleştiren başyapıt.",
                        "category_name": "Empresyonizm & Post-Empresyonizm"
            },
            {
                        "title": "Ayçiçekleri",
                        "artist": "Vincent van Gogh",
                        "year": 1888,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/46/Vincent_Willem_van_Gogh_127.jpg/330px-Vincent_Willem_van_Gogh_127.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Arles döneminin parlak sarı tonlarıyla yaşam enerjisini ve doğanın döngüsünü kutlayan ünlü natürmort.",
                        "category_name": "Empresyonizm & Post-Empresyonizm"
            },
            {
                        "title": "Gece Kafe Terası",
                        "artist": "Vincent van Gogh",
                        "year": 1888,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/86/Van_Gogh_-_Terrace_of_a_Caf%C3%A9_at_Night_%28Place_du_Forum%29_1888.jpg/330px-Van_Gogh_-_Terrace_of_a_Caf%C3%A9_at_Night_%28Place_du_Forum%29_1888.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Sıcak sarı kafe ışığı ile derin mavi yıldızlı gökyüzü arasındaki kontrastı siyah kullanmadan yaratan Van Gogh şaheseri.",
                        "category_name": "Empresyonizm & Post-Empresyonizm"
            },
            {
                        "title": "Grande Jatte Adası'nda Bir Pazar Öğleden Sonrası",
                        "artist": "Georges Seurat",
                        "year": 1886,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/7d/A_Sunday_on_La_Grande_Jatte%2C_Georges_Seurat%2C_1884.jpg/330px-A_Sunday_on_La_Grande_Jatte%2C_Georges_Seurat%2C_1884.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Milyonlarca küçük renk noktasının yan yana dizildiği Puantilizm (Noktacılık) tekniğinin en büyük anıtsal örneği.",
                        "category_name": "Empresyonizm & Post-Empresyonizm"
            },
            {
                        "title": "Öpücük (The Kiss - Klimt)",
                        "artist": "Gustav Klimt",
                        "year": 1908,
                        "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/40/The_Kiss_-_Gustav_Klimt_-_Google_Cultural_Institute.jpg/330px-The_Kiss_-_Gustav_Klimt_-_Google_Cultural_Institute.jpg?utm_source=en.wikipedia.org&utm_campaign=api&utm_content=thumbnail",
                        "description": "Viyana Secession döneminin altın varak ve süslemeci geometrik motiflerle bezenmiş en ünlü sembolist tablosu.",
                        "category_name": "Empresyonizm & Post-Empresyonizm"
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
        print(f"Tohumlama tamamlandı! Toplam {len(artworks_data)} eser işlendi.")

    except Exception as e:
        db.rollback()
        print(f"Hata oluştu: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()
