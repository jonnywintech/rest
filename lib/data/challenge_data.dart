// Sadržaj 28-dnevnog izazova. Rodni oblici: {muški|ženski}.

class ChallengeWeek {
  const ChallengeWeek(this.number, this.emoji, this.title, this.subtitle);

  final int number;
  final String emoji;
  final String title;
  final String subtitle;
}

class ChallengeDay {
  const ChallengeDay({
    required this.day,
    required this.emoji,
    required this.title,
    required this.minutes,
    required this.lesson,
    required this.task,
    required this.reflection,
  });

  final int day;
  final String emoji;
  final String title;
  final int minutes;
  final List<String> lesson;
  final String task;
  final String reflection;
}

const challengeLength = 28;

const challengeWeeks = [
  ChallengeWeek(1, '🌤️', 'Zastani i primeti',
      'Učimo da prepoznamo stres u mislima i telu'),
  ChallengeWeek(2, '🌿', 'Telo i energija',
      'Vraćamo snagu kroz san, pokret i odmor'),
  ChallengeWeek(3, '🛡️', 'Granice i misli',
      'Čuvamo svoju energiju i učimo da budemo blaži prema sebi'),
  ChallengeWeek(4, '☀️', 'Radost i nove navike',
      'Vraćamo smisao i gradimo rutinu koja traje'),
];

ChallengeWeek weekOf(int day) => challengeWeeks[((day - 1) ~/ 7).clamp(0, 3)];

ChallengeDay dayContent(int day) => challengeDays[day - 1];

const challengeDays = <ChallengeDay>[
  // ───────────── Nedelja 1: Zastani i primeti ─────────────
  ChallengeDay(
    day: 1,
    emoji: '🧭',
    title: 'Gde sam sada?',
    minutes: 5,
    lesson: [
      'Izgaranje retko dolazi iznenada. Gradi se polako – kroz neprospavane noći, preskočene pauze i stalni osećaj da kasniš za obavezama. Zato ga često primetimo tek kada nas potpuno iscrpi.',
      'Prvi korak ka oporavku nije velika promena, već iskren pogled na to kako si zapravo. Ne kako bi trebalo da budeš, ne kako izgledaš drugima – nego kako se osećaš sada, u ovom trenutku.',
      'Danas samo posmatraš. Bez osuđivanja i bez popravljanja. Svest je temelj na kome ćemo graditi narednih 27 dana.',
    ],
    task:
        'Tri puta danas (ujutru, popodne i uveče) zastani na jedan minut i oceni svoju energiju od 1 do 10. Zabeleži raspoloženje u aplikaciji bar jednom.',
    reflection: 'Šta ti je danas najviše oduzelo energiju, a šta ti je dalo snagu?',
  ),
  ChallengeDay(
    day: 2,
    emoji: '🔍',
    title: 'Tri lica izgaranja',
    minutes: 5,
    lesson: [
      'Svetska zdravstvena organizacija opisuje izgaranje kroz tri znaka: iscrpljenost i nedostatak energije, sve veću distancu ili cinizam prema poslu, i osećaj da si manje uspeš{an|na} u onome što radiš.',
      'Kod nekoga dominira umor – telo je teško, a odmor ne pomaže. Kod drugih se javlja ravnodušnost: „Nije me briga, samo da prođe dan.“ Treći primećuju da im ništa ne ide od ruke i počinju da sumnjaju u sebe.',
      'Kada znaš koji je znak kod tebe najizraženiji, lakše biraš šta ti najviše treba: odmor, ponovno povezivanje sa smislom ili vraćanje samopouzdanja.',
    ],
    task:
        'Pročitaj tri znaka još jednom i za svaki oceni od 1 do 10 koliko se odnosi na tebe. Zapiši brojeve u odgovoru ispod.',
    reflection: 'Koji znak najviše prepoznaješ kod sebe i otprilike od kada?',
  ),
  ChallengeDay(
    day: 3,
    emoji: '🗺️',
    title: 'Mapa stresa',
    minutes: 10,
    lesson: [
      'Stres je teško kontrolisati dok je samo maglovit osećaj da je „svega previše“. Kada ga raščlaniš na konkretne stvari, odjednom postaje nešto sa čim možeš da radiš.',
      'Korisna je podela na tri kruga: stvari na koje možeš direktno da utičeš, stvari na koje možeš delimično da utičeš i stvari na koje ne možeš da utičeš – poput tuđih odluka, vremena ili prošlosti.',
      'Energija koju trošimo na treći krug je energija koja nam nedostaje za prvi. Cilj nije da prestaneš da brineš, već da brigu usmeriš tamo gde ima efekta.',
    ],
    task:
        'Zapiši 5 stvari koje te trenutno opterećuju i svaku svrstaj u jedan od tri kruga: „mogu da utičem“, „delimično“ ili „ne mogu da utičem“.',
    reflection:
        'Koji jedan mali korak možeš ove nedelje da napraviš za nešto iz kruga „mogu da utičem“?',
  ),
  ChallengeDay(
    day: 4,
    emoji: '🌬️',
    title: 'Disanje kao kočnica',
    minutes: 5,
    lesson: [
      'Kada smo pod stresom, disanje postaje plitko i ubrzano, a telo ostaje u stanju pripravnosti. Dobra vest je da disanje radi i u suprotnom smeru: kada svesno usporiš dah, šalješ telu signal da je bezbedno.',
      'Posebno pomaže produženi izdah. Kada izdišeš duže nego što udišeš, aktivira se deo nervnog sistema zadužen za smirivanje i oporavak. Srce usporava, a mišići se opuštaju.',
      'Ovo je alat koji imaš uvek uz sebe – na sastanku, u gužvi, pred spavanje. Što ga češće vežbaš kada si mir{an|na}, lakše ćeš ga koristiti kada ti zaista zatreba.',
    ],
    task:
        'Tri puta danas uradi po 3 minuta disanja: udah na nos dok brojiš do 4, izdah na usta dok brojiš do 6.',
    reflection: 'Kako se telo osećalo pre, a kako posle vežbe disanja?',
  ),
  ChallengeDay(
    day: 5,
    emoji: '🫀',
    title: 'Signali tela',
    minutes: 10,
    lesson: [
      'Stres se ne zadržava samo u mislima. Taloži se u telu: u stegnutoj vilici, podignutim ramenima, plitkom dahu, stomaku koji se steže. Telo često zna da nam je teško pre nego što to sebi priznamo.',
      'Skeniranje tela je jednostavna vežba pažnje: polako, od stopala do temena, primećuješ svaki deo tela i šta osećaš u njemu – toplotu, težinu, napetost ili ništa posebno.',
      'Ne pokušavaš ništa da promeniš. Samo primećuješ. Često se napetost sama malo opusti kada joj posvetiš pažnju.',
    ],
    task:
        'Pred spavanje lezi, zatvori oči i polako „prošetaj“ pažnjom kroz telo, od stopala do glave, oko 5 minuta.',
    reflection: 'Gde u telu najčešće nosiš napetost?',
  ),
  ChallengeDay(
    day: 6,
    emoji: '🔋',
    title: 'Energetski budžet',
    minutes: 10,
    lesson: [
      'Zamisli da tvoja energija ima dnevni budžet. Neke aktivnosti ga troše – sastanci, svađe, gužva, beskonačno skrolovanje. Druge ga dopunjuju – šetnja, dobar razgovor, smeh, tišina.',
      'Kod izgaranja je budžet dugo u minusu: trošimo više nego što obnavljamo. Ne možemo uvek da izbacimo ono što nas prazni, ali možemo svesno da dodamo ono što nas puni.',
      'Punioci ne moraju biti veliki. Pet minuta na suncu, omiljena pesma ili topao čaj na miru su sitnice koje se sabiraju.',
    ],
    task: 'Napravi dve liste: 5 stvari koje te prazne i 5 stvari koje te pune energijom.',
    reflection: 'Koji jedan punilac možeš sutra da ubaciš u svoj dan?',
  ),
  ChallengeDay(
    day: 7,
    emoji: '🌤️',
    title: 'Osvrt na prvu nedelju',
    minutes: 5,
    lesson: [
      'Prošla je prva nedelja. Možda nisi uradi{o|la} sve zadatke – i to je u redu. Izazov nije test, već prostor da bolje upoznaš sebe.',
      'Ove nedelje si uči{o|la} da primećuješ: energiju, izvore stresa, dah i telo. Ta svest je osnova za sve što sledi.',
      'Pogledaj svoje zapise raspoloženja u Dnevniku. Da li vidiš neki obrazac – određene dane, ljude ili situacije koje se ponavljaju?',
    ],
    task: 'Otvori Dnevnik → Raspoloženje i pregledaj zapise iz protekle nedelje.',
    reflection: 'Šta si ove nedelje sazna{o|la} o sebi?',
  ),

  // ───────────── Nedelja 2: Telo i energija ─────────────
  ChallengeDay(
    day: 8,
    emoji: '🌙',
    title: 'San je temelj',
    minutes: 10,
    lesson: [
      'Kada smo iscrpljeni, san je prvo što strada – a upravo nam je tada najpotrebniji. Tokom sna mozak obrađuje emocije, a telo se oporavlja od stresa.',
      'Nekoliko navika pravi veliku razliku: odlazak na spavanje i buđenje u približno isto vreme, tamna i prohladna soba, bez kofeina u kasnim popodnevnim satima i bez ekrana neposredno pred san.',
      'Ekran nije problem samo zbog svetla, već i zbog sadržaja: poruke i vesti drže um budnim. Sat vremena pred spavanje daj mozgu znak da se dan završava.',
    ],
    task: 'Odredi „vreme gašenja ekrana“ 45 minuta pre spavanja i drži ga se večeras.',
    reflection: 'Šta ti najviše kvari san i šta od toga možeš da promeniš?',
  ),
  ChallengeDay(
    day: 9,
    emoji: '⏸️',
    title: 'Mikro-pauze',
    minutes: 5,
    lesson: [
      'Pažnja prirodno opada posle sat-dva intenzivnog rada. Ako tada nastavimo „na silu“, radimo sporije, grešimo češće i umor se gomila do kraja dana.',
      'Mikro-pauza traje samo 2 do 5 minuta, ali deluje samo ako je prava pauza: ustani, protegni se, pogledaj kroz prozor u daljinu, popij vodu. Skrolovanje telefona nije pauza – mozak i dalje obrađuje informacije.',
      'Male pauze tokom dana čuvaju energiju za veče, za ljude i stvari koje voliš.',
    ],
    task:
        'Podesi podsetnik za bar 3 mikro-pauze danas. U svakoj ustani i budi 2 minuta bez ekrana.',
    reflection: 'Kako su pauze uticale na tvoj fokus i raspoloženje?',
  ),
  ChallengeDay(
    day: 10,
    emoji: '🚶',
    title: 'Pokret koji prija',
    minutes: 15,
    lesson: [
      'Kada smo iscrpljeni, trening deluje kao još jedna obaveza. Zato danas ne govorimo o vežbanju, već o pokretu koji prija.',
      'Fizička aktivnost pomaže telu da „potroši“ hormone stresa. Već desetak minuta šetnje može da popravi raspoloženje i smanji napetost.',
      'Najbolji pokret je onaj koji ćeš zaista raditi: šetnja, ples u kuhinji, istezanje, vožnja bicikla. Ne meri brzinu ni kalorije – samo primeti kako se osećaš.',
    ],
    task:
        'Prošetaj 10 do 15 minuta bez telefona u ruci. Primećuj šta vidiš, čuješ i mirišeš.',
    reflection: 'Šta si primeti{o|la} tokom šetnje i kako si se oseća{o|la} posle?',
  ),
  ChallengeDay(
    day: 11,
    emoji: '🥗',
    title: 'Hrana, voda i energija',
    minutes: 5,
    lesson: [
      'Umor nije uvek samo psihički. Preskočeni obroci, malo vode i previše kafe mogu da pojačaju iscrpljenost, razdražljivost i pad koncentracije.',
      'Kofein deluje satima, pa kafa posle ranog popodneva može da naruši kvalitet sna čak i kada zaspiš bez problema. Dehidracija se često oseća kao umor ili glavobolja.',
      'Ne treba ti stroga dijeta, već ritam: redovni obroci, voda nadohvat ruke i poslednja kafa do ranog popodneva.',
    ],
    task: 'Danas popij bar 6 čaša vode i zapiši u koliko sati piješ kafu.',
    reflection:
        'Kada ti energija najviše pada tokom dana i šta tada obično jedeš ili piješ?',
  ),
  ChallengeDay(
    day: 12,
    emoji: '📵',
    title: 'Digitalni predah',
    minutes: 10,
    lesson: [
      'Telefon nas drži u stanju stalne dostupnosti. Svako obaveštenje je mali prekid, a mozgu treba vremena da se vrati na ono što je radio.',
      'Kada smo stalno „na vezi“, nikada se zapravo ne odmaramo – čak ni na kauču. Granica prema ekranu je zapravo granica koja čuva tvoju pažnju.',
      'Ne moraš da se odrekneš telefona. Dovoljno je da ti odlučuješ kada ga koristiš, a ne obrnuto.',
    ],
    task:
        'Isključi obaveštenja za aplikacije koje nisu neophodne i provedi bar 1 sat danas bez telefona.',
    reflection: 'Kako ti je bilo bez telefona? Šta ti je nedostajalo, a šta ti je prijalo?',
  ),
  ChallengeDay(
    day: 13,
    emoji: '🛋️',
    title: 'Odmor nije nagrada',
    minutes: 5,
    lesson: [
      'Mnogi misle da odmor treba zaslužiti – tek kada se sve obaveze završe. Ali obaveze se nikada ne završe, pa odmor stalno odlažemo.',
      'Odmor je potreba, kao hrana i san. I ima više vrsta: fizički (san, istezanje), mentalni (pauza od razmišljanja), društveni (vreme sa ljudima koji nas pune ili vreme bez ljudi), kreativni (priroda, umetnost) i čulni (tišina, manje ekrana i buke).',
      'Kada znaš koja vrsta odmora ti nedostaje, odmor postaje mnogo delotvorniji.',
    ],
    task:
        'Zakaži sebi 30 minuta odmora u kalendaru kao da je važan sastanak – i ispoštuj ga.',
    reflection: 'Koja vrsta odmora ti najviše nedostaje?',
  ),
  ChallengeDay(
    day: 14,
    emoji: '🌿',
    title: 'Osvrt na drugu nedelju',
    minutes: 5,
    lesson: [
      'Dve nedelje su iza tebe. Ove nedelje fokus je bio na telu: san, pauze, pokret, hrana, ekrani i odmor.',
      'Telo često prvo reaguje na promene. Možda primećuješ da lakše zaspiš ili da imaš malo više energije popodne. A možda još ništa ne primećuješ – i to je normalno. Navike rade tiho.',
      'Izaberi jednu naviku iz ove nedelje koju želiš da zadržiš. Jedna navika koja traje vredi više od pet koje odustanu posle tri dana.',
    ],
    task:
        'Izaberi jednu naviku iz ove nedelje i odluči kada ćeš je tačno raditi (npr. „pauza svakog dana u 11h“).',
    reflection: 'Koja navika iz ove nedelje ti je najviše prijala i zašto?',
  ),

  // ───────────── Nedelja 3: Granice i misli ─────────────
  ChallengeDay(
    day: 15,
    emoji: '🚧',
    title: 'Šta su granice?',
    minutes: 5,
    lesson: [
      'Granice nisu zidovi koji odbijaju ljude. One su jasan znak šta je za tebe u redu, a šta nije – i čuvaju tvoje vreme, energiju i odnose.',
      'Kod izgaranja granice su često tanke: kažemo „da“ kada mislimo „ne“, odgovaramo na poruke kasno uveče, preuzimamo tuđe obaveze da ne bismo nikoga razočarali.',
      'Svako „da“ nečemu istovremeno je „ne“ nečemu drugom – često odmoru, porodici ili sebi.',
    ],
    task:
        'Zapiši 3 situacije iz poslednjih nedelju dana u kojima si reka{o|la} „da“, a zapravo si žele{o|la} da kažeš „ne“.',
    reflection: 'Šta te je sprečilo da kažeš „ne“ u tim situacijama?',
  ),
  ChallengeDay(
    day: 16,
    emoji: '✋',
    title: 'Umetnost reči „ne“',
    minutes: 10,
    lesson: [
      'Odbijanje ne mora biti grubo. Jednostavna formula: zahvali, jasno odbij i, ako želiš, ponudi alternativu. Na primer: „Hvala što si se setio mene. Ove nedelje ne mogu da preuzmem taj zadatak, ali mogu da pomognem sledeće.“',
      'Ne moraš da daješ dugačka objašnjenja. Što više opravdavaš svoje „ne“, to ono više zvuči kao predmet pregovora.',
      'Prvih nekoliko puta biće neprijatno. To je normalno – nelagodnost ne znači da grešiš, već da radiš nešto novo.',
    ],
    task:
        'Napiši jednu rečenicu odbijanja koja ti zvuči prirodno i izgovori je naglas. Pokušaj da je iskoristiš bar jednom ove nedelje.',
    reflection: 'Kako se osećaš kada zamisliš da nekome kažeš „ne“?',
  ),
  ChallengeDay(
    day: 17,
    emoji: '🗣️',
    title: 'Unutrašnji kritičar',
    minutes: 10,
    lesson: [
      'U glavi mnogih od nas živi glas koji kaže: „Moraš više“, „Nisi dovoljno dob{ar|ra}“, „Opet si zabrlja{o|la}“. Kod izgaranja taj glas postaje sve glasniji.',
      'Kritičar često koristi reči kao što su „uvek“, „nikad“, „moram“ i „trebalo bi“. Te reči ne opisuju stvarnost, već pritisak.',
      'Prvi korak nije da ga ućutkaš, već da ga primetiš. Kada uhvatiš kritičku misao, zapitaj se: „Da li bih ovo reka{o|la} dragom prijatelju?“',
    ],
    task:
        'Danas uhvati 3 kritičke misli o sebi i zapiši ih tačno onako kako zvuče u tvojoj glavi.',
    reflection: 'Koja kritička misao ti se najčešće vraća?',
  ),
  ChallengeDay(
    day: 18,
    emoji: '🔄',
    title: 'Preformulisanje misli',
    minutes: 10,
    lesson: [
      'Misli nisu činjenice. One su tumačenja – a kada smo umorni, često su mnogo mračnije od stvarnosti.',
      'Uzmi jednu tešku misao, na primer: „Nikad ništa ne završim na vreme.“ Zatim potraži dokaze za i protiv nje. Da li je zaista „nikad“? Kada si poslednji put nešto završi{o|la} na vreme?',
      'Na kraju napiši uravnoteženiju verziju: „Ponekad kasnim kada imam previše obaveza, ali mnoge stvari završim na vreme.“ Cilj nije lažni optimizam, već realnija slika.',
    ],
    task:
        'Izaberi jednu misao sa jučerašnje liste i napiši njenu uravnoteženiju verziju.',
    reflection: 'Kako se osećaš kada pročitaš uravnoteženu verziju svoje misli?',
  ),
  ChallengeDay(
    day: 19,
    emoji: '🎯',
    title: 'Dovoljno dobro',
    minutes: 5,
    lesson: [
      'Perfekcionizam je jedan od najčešćih saputnika izgaranja. Kada sve mora da bude savršeno, svaki zadatak traje duže, a osećaj zadovoljstva nikako da dođe.',
      'Za većinu stvari, najveći deo kvaliteta postiže se razumnim trudom. Poslednje „doterivanje“ često odnosi najviše vremena, a retko ko primeti razliku.',
      '„Dovoljno dobro“ ne znači nemarno. Znači da svesno biraš gde ulažeš punu snagu, a gde je dobro – dovoljno.',
    ],
    task: 'Izaberi jedan zadatak danas i uradi ga „dovoljno dobro“ – bez dodatnog doterivanja.',
    reflection: 'Šta se desilo kada si sta{o|la} na „dovoljno dobro“?',
  ),
  ChallengeDay(
    day: 20,
    emoji: '💛',
    title: 'Samosaosećanje',
    minutes: 10,
    lesson: [
      'Prema prijateljima smo često nežni i puni razumevanja, a prema sebi strogi i nemilosrdni. Samosaosećanje znači da se prema sebi ophodiš onako kako bi se ophodi{o|la} prema dobrom prijatelju u teškom trenutku.',
      'Ono ima tri dela: primetiti da ti je teško, setiti se da su teškoće deo ljudskog iskustva i da nisi sam{|a} u njima, i uputiti sebi ljubaznu reč umesto kritike.',
      'Istraživanja ukazuju da samosaosećanje ne čini ljude lenjima – naprotiv, lakše se oporavljamo od neuspeha i spremniji smo da pokušamo ponovo.',
    ],
    task:
        'Napiši sebi kratko pismo podrške, kao da pišeš prijatelju koji prolazi kroz isto što i ti.',
    reflection: 'Šta ti je bilo najteže da sebi napišeš, a šta ti je najviše prijalo?',
  ),
  ChallengeDay(
    day: 21,
    emoji: '🛡️',
    title: 'Osvrt na treću nedelju',
    minutes: 5,
    lesson: [
      'Ova nedelja je bila zahtevna: granice, kritičke misli, perfekcionizam. To su obrasci koji se grade godinama, pa se ne menjaju za sedam dana.',
      'Ako si bar jednom reka{o|la} „ne“, uhvati{o|la} kritičku misao ili sebi uputi{o|la} blažu reč – to je stvaran napredak.',
      'Primeti i male pobede. Mozak lakše ponavlja ono što doživi kao uspeh.',
    ],
    task:
        'Zapiši jednu situaciju iz ove nedelje u kojoj si postupi{o|la} drugačije nego ranije.',
    reflection: 'Gde ti je ove nedelje bilo najlakše, a gde najteže da čuvaš svoje granice?',
  ),

  // ───────────── Nedelja 4: Radost i nove navike ─────────────
  ChallengeDay(
    day: 22,
    emoji: '🌼',
    title: 'Mali izvori radosti',
    minutes: 15,
    lesson: [
      'Kod izgaranja se radost polako povlači. Prestajemo da radimo stvari koje volimo jer „nemamo vremena“ ili „nemamo snage“ – a upravo nas one pune.',
      'Radost ne mora biti veliki događaj. To može biti omiljena pesma, kafa na suncu, igra sa ljubimcem ili hobi koji si odavno zapostavi{o|la}.',
      'Danas ti je zadatak da radiš nešto samo zato što ti prija. Bez cilja, bez produktivnosti.',
    ],
    task: 'Odvoji 10 do 20 minuta za nešto što radiš isključivo zato što ti prija.',
    reflection: 'Šta si radi{o|la} i kako si se oseća{o|la} dok je trajalo?',
  ),
  ChallengeDay(
    day: 23,
    emoji: '🙏',
    title: 'Zahvalnost',
    minutes: 5,
    lesson: [
      'Kada smo iscrpljeni, mozak prirodno više primećuje ono što ne valja. To je zaštitni mehanizam, ali nas drži u stalnoj napetosti.',
      'Vežba zahvalnosti ne poriče teškoće. Ona samo širi sliku – podseća nas da pored problema postoje i stvari koje su dobre.',
      'Najbolje deluje kada je konkretna: ne „zahval{an|na} sam na porodici“, već „drago mi je što me je sestra danas pozvala“.',
    ],
    task:
        'Uveče zapiši 3 dobre stvari koje su se danas desile i zašto misliš da su se desile.',
    reflection: 'Koje su tri dobre stvari danas?',
  ),
  ChallengeDay(
    day: 24,
    emoji: '🤝',
    title: 'Povezanost',
    minutes: 10,
    lesson: [
      'Izgaranje često vodi u povlačenje: otkazujemo viđanja i ne javljamo se jer nemamo snage. A upravo nam bliski ljudi pomažu da lakše podnesemo stres.',
      'Ne treba ti veliko društvo. Jedan topao razgovor, poruka podrške ili zajednička šetnja mogu da promene ceo dan.',
      'Ako ti je teško, nije sramota reći nekome: „Imam težak period.“ Ljudi često žele da pomognu, samo ne znaju kako.',
    ],
    task:
        'Javi se danas nekome kome se dugo nisi javi{o|la} – porukom, pozivom ili uživo.',
    reflection: 'Kako je bilo javiti se toj osobi?',
  ),
  ChallengeDay(
    day: 25,
    emoji: '🧭',
    title: 'Tvoje vrednosti',
    minutes: 10,
    lesson: [
      'Izgaranje se često javlja kada dugo živimo u raskoraku sa onim što nam je važno – kada naši dani pripadaju tuđim prioritetima.',
      'Vrednosti su kompas: porodica, zdravlje, sloboda, kreativnost, sigurnost, učenje, pomaganje drugima... One nisu ciljevi koje treba dostići, već pravac u kome želiš da ideš.',
      'Kada znaš svoje vrednosti, lakše donosiš odluke – i lakše kažeš „ne“ onome što ih ne podržava.',
    ],
    task:
        'Izaberi 3 vrednosti koje su ti najvažnije i za svaku zapiši jednu malu stvar koju ove nedelje možeš da uradiš u skladu sa njom.',
    reflection: 'Koliko tvoj prosečan dan odražava vrednosti koje si izabra{o|la}?',
  ),
  ChallengeDay(
    day: 26,
    emoji: '🌅',
    title: 'Rutina koja štiti',
    minutes: 10,
    lesson: [
      'Rutine štede energiju jer ne moramo stalno da donosimo odluke. Dobra jutarnja ili večernja rutina postaje sidro – nešto stabilno i u najhaotičnijim danima.',
      'Rutina ne mora biti duga. Deset minuta je dovoljno: čaša vode, malo istezanja i tri minuta disanja ujutru; ili ugašen ekran, topao tuš i zapis u dnevnik uveče.',
      'Iskoristi ono što ti je u ovom izazovu najviše prijalo i spoji to u svoju malu rutinu.',
    ],
    task: 'Osmisli svoju rutinu od 10 minuta (jutarnju ili večernju) i isprobaj je danas.',
    reflection: 'Kako izgleda tvoja rutina i šta bi moglo da te omete da je se držiš?',
  ),
  ChallengeDay(
    day: 27,
    emoji: '🧰',
    title: 'Plan za teške dane',
    minutes: 10,
    lesson: [
      'Biće još teških dana – to je deo života. Razlika je u tome što sada možeš da ih dočekaš pripremlje{n|na}.',
      'Plan prve pomoći ima tri dela: rani znaci upozorenja (npr. loš san, razdražljivost, povlačenje od ljudi), stvari koje ti pomažu (disanje, šetnja, razgovor) i ljudi kojima možeš da se obratiš.',
      'Ako primetiš da se znaci gomilaju nedeljama i da ti ništa ne pomaže, potraži stručnu pomoć – lekara opšte prakse, psihologa ili psihoterapeuta. To je znak brige o sebi, a ne slabosti.',
    ],
    task:
        'Napiši svoj „plan prve pomoći“: 3 rana znaka upozorenja, 3 stvari koje pomažu i 2 osobe kojima možeš da se obratiš.',
    reflection: 'Koji su tvoji najraniji znaci da ulaziš u preopterećenje?',
  ),
  ChallengeDay(
    day: 28,
    emoji: '🎉',
    title: 'Novi početak',
    minutes: 10,
    lesson: [
      'Stiga{o|la} si do kraja izazova! Bez obzira na to koliko je zadataka urađeno, uloži{o|la} si vreme i pažnju u sebe – a to je mnogo.',
      'Oporavak od izgaranja nije prava linija. Biće boljih i lošijih dana. Ali sada imaš alate: disanje, pauze, granice, blaži unutrašnji glas, rutinu i plan za teške dane.',
      'Ponovi procenu u Profilu i uporedi rezultat sa onim sa početka. Zatim odluči šta želiš da poneseš dalje.',
    ],
    task:
        'Ponovi procenu izgaranja (Profil → Ponovi procenu) i uporedi rezultat sa početnim.',
    reflection: 'Šta želiš da poneseš dalje iz ovih 28 dana?',
  ),
];
