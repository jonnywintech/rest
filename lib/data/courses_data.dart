import 'package:flutter/material.dart';

class Lesson {
  const Lesson(this.id, this.title, this.minutes, this.paragraphs);

  final String id;
  final String title;
  final int minutes;
  final List<String> paragraphs;
}

class Course {
  const Course({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.lessons,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final Color color;
  final List<Lesson> lessons;
}

const courses = <Course>[
  Course(
    id: 'burnout',
    emoji: '🔥',
    title: 'Razumeti izgaranje',
    description: 'Šta je izgaranje i po čemu se razlikuje od običnog stresa',
    color: Color(0xFFF2994A),
    lessons: [
      Lesson('burnout_1', 'Stres ili izgaranje?', 3, [
        'Stres i izgaranje nisu isto. Stres obično znači „previše“: previše obaveza, pritiska i brzine. Pod stresom se i dalje trudimo i verujemo da će biti bolje kada sve završimo.',
        'Izgaranje je češće „premalo“: premalo energije, motivacije i nade. Umesto užurbanosti javlja se praznina i osećaj da više nemaš šta da daš.',
        'Hroničan stres koji traje mesecima, bez dovoljno oporavka, može da preraste u izgaranje. Zato je važno reagovati na vreme – dok je to još „previše“, a ne „ništa“.',
      ]),
      Lesson('burnout_2', 'Kako se razvija', 4, [
        'Izgaranje se obično razvija postepeno. Često počinje velikim entuzijazmom i željom da se dokažemo, zbog čega zanemarujemo odmor i sopstvene potrebe.',
        'Vremenom se javljaju umor, razdražljivost i povlačenje od ljudi. Stvari koje su nekad bile važne počinju da deluju besmisleno, a odmor više ne vraća energiju.',
        'Što ranije prepoznaš ove znake, to je oporavak lakši i brži. Male promene u ranoj fazi mogu da spreče velike posledice kasnije.',
      ]),
      Lesson('burnout_3', 'Kada potražiti pomoć', 3, [
        'Samopomoć je važna, ali ponekad nije dovoljna. Obrati se lekaru ili psihologu ako iscrpljenost traje nedeljama uprkos odmoru, ako dugo imaš problema sa snom ili ako ti ništa više ne pričinjava zadovoljstvo.',
        'Simptomi izgaranja mogu da liče na depresiju, anksioznost ili neka telesna stanja (npr. probleme sa štitnom žlezdom ili anemiju), pa je dobro da ih proveri stručnjak.',
        'Ako imaš misli o samopovređivanju, odmah se obrati nekome: pozovi Hitnu pomoć (194) ili Centar Srce (0800 300 303, svakog dana od 14 do 23h, besplatno).',
      ]),
    ],
  ),
  Course(
    id: 'sleep',
    emoji: '🌙',
    title: 'San i oporavak',
    description: 'Kako da san ponovo postane izvor energije',
    color: Color(0xFF5C8ED6),
    lessons: [
      Lesson('sleep_1', 'Zašto je san važan', 3, [
        'San nije pauza u životu – to je vreme kada se mozak i telo popravljaju. Tokom sna mozak obrađuje utiske i emocije dana, a telo se oporavlja od stresa.',
        'Kada spavamo premalo, sve deluje teže: lakše se iznerviramo, teže se koncentrišemo i više nas privlače brza hrana i kofein. Tako nastaje začarani krug umora.',
        'Većini odraslih je potrebno 7 do 9 sati sna. Ali nije važna samo dužina – važni su i redovnost i kvalitet.',
      ]),
      Lesson('sleep_2', 'Večernja rutina', 4, [
        'Mozak ne može da pređe iz „radnog režima“ u san kao na prekidač. Treba mu prelazni period od 30 do 60 minuta.',
        'Prigušeno svetlo, topao tuš, lagano istezanje, čitanje papirne knjige ili zapis u dnevnik – sve to šalje signal da se dan završava.',
        'Ako ti misli ne daju mira, zapiši na papir sve što te brine i šta ćeš sutra uraditi u vezi sa tim. „Istovar“ misli olakšava uspavljivanje.',
      ]),
      Lesson('sleep_3', 'Kada ne možeš da zaspiš', 3, [
        'Ako ležiš bud{an|na} duže od dvadesetak minuta, ustani i radi nešto mirno pri prigušenom svetlu dok ne osetiš pospanost. Krevet treba da ostane povezan sa spavanjem, a ne sa brigom.',
        'Izbegavaj gledanje u sat – računanje koliko je ostalo do jutra samo pojačava napetost.',
        'Probaj disanje 4-6 ili opuštanje mišića. A ako nesanica traje duže od nekoliko nedelja, razgovaraj sa lekarom.',
      ]),
    ],
  ),
  Course(
    id: 'calm',
    emoji: '🌬️',
    title: 'Brzo smirivanje',
    description: 'Tehnike koje deluju za nekoliko minuta',
    color: Color(0xFF2BAA8F),
    lessons: [
      Lesson('calm_1', 'Disanje 4-6', 3, [
        'Kada te preplavi stres, najbrži put do smirenja vodi kroz dah. Udahni na nos dok brojiš do 4, a zatim polako izdahni na usta dok brojiš do 6.',
        'Produženi izdah usporava rad srca i signalizira telu da opasnost prolazi. Već nekoliko minuta ovakvog disanja može da smanji napetost.',
        'Vežbaj i kada si mir{an|na}, da bi ti tehnika bila pri ruci kada ti je teško.',
      ]),
      Lesson('calm_2', 'Tehnika 5-4-3-2-1', 3, [
        'Kada misli jure, vrati pažnju u sadašnji trenutak preko čula.',
        'Primeti 5 stvari koje vidiš, 4 stvari koje možeš da dodirneš, 3 zvuka koja čuješ, 2 mirisa koja osećaš i 1 ukus.',
        'Ova tehnika „uzemljenja“ pomaže kod anksioznosti i preplavljenosti jer zaokupi pažnju onim što je stvarno i sada, umesto brigama o budućnosti.',
      ]),
      Lesson('calm_3', 'Opuštanje mišića', 5, [
        'Progresivna mišićna relaksacija zasniva se na jednostavnoj ideji: kada mišić namerno zategneš pa ga opustiš, lakše osetiš razliku između napetosti i opuštanja.',
        'Kreni od stopala: zategni mišiće 5 sekundi, zatim ih opusti i 10 sekundi primećuj osećaj. Nastavi redom: listovi, butine, stomak, šake, ruke, ramena i lice.',
        'Cela vežba traje 10 do 15 minuta i odlično deluje pred spavanje.',
      ]),
    ],
  ),
  Course(
    id: 'work',
    emoji: '🛡️',
    title: 'Granice na poslu',
    description: 'Kako da posao ne pojede ceo tvoj život',
    color: Color(0xFF8E6BD8),
    lessons: [
      Lesson('work_1', 'Prepoznaj preopterećenje', 3, [
        'Preopterećenje se retko najavi. Počinje kao „samo još ovaj zadatak“ i „samo ove nedelje“, sve dok vanredno ne postane redovno.',
        'Znaci da je vreme za promenu: redovno radiš posle radnog vremena, proveravaš poruke na odmoru, osećaš krivicu kada ne radiš i nemaš vremena za osnovne potrebe.',
        'Zapiši na šta zaista trošiš vreme tokom jedne nedelje. Konkretni podaci olakšavaju razgovor – i sa sobom i sa drugima.',
      ]),
      Lesson('work_2', 'Razgovor o obimu posla', 4, [
        'Razgovor sa nadređenim o preopterećenju nije priznanje slabosti, već odgovorno ponašanje. Iscrpljen čovek ne radi dobro ni za sebe ni za firmu.',
        'Pripremi se: navedi konkretne zadatke i koliko vremena oduzimaju, pa predloži rešenje – prioritete, rokove ili raspodelu posla. Umesto „Ne mogu više“ pitaj „Koji od ova tri zadatka je prioritet ove nedelje?“',
        'Govori o činjenicama i rešenjima, a ne o krivici. Tako razgovor postaje zajedničko traženje rešenja.',
      ]),
      Lesson('work_3', 'Kraj radnog dana', 3, [
        'Kada radiš od kuće ili stalno nosiš posao u telefonu, granica između posla i odmora nestaje. Zato ti treba jasan ritual završetka dana.',
        'Na kraju dana zapiši 3 zadatka za sutra, zatvori laptop, isključi poslovna obaveštenja i uradi nešto što označava prelaz – šetnju, tuš ili presvlačenje.',
        'Tako mozgu daješ jasan signal: posao je za danas gotov. Sutra ćeš nastaviti odmorni{ji|ja}.',
      ]),
    ],
  ),
];

Course courseById(String id) => courses.firstWhere((c) => c.id == id);

int get totalLessons => courses.fold(0, (sum, c) => sum + c.lessons.length);
