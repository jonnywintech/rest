# Predah

28-dnevni izazov protiv izgaranja – lična aplikacija za samopomoć (Flutter, Android + Web), inspirisana Liven anti-burnout kvizom.

## Šta sadrži

- **Kviz (17 koraka)** – izbor pola, pitanja, skale, info ekrani, ime → animirana analiza → rezultat (nivo izgaranja 0–100, iscrpljenost / stres / motivacija, profil, plan).
- **Danas** – pozdrav, današnji dan izazova, brzi unos raspoloženja, pitanje dana, Mira, kratki kursevi.
- **Izazov** – 28 dana u 4 nedelje (lekcija, zadatak, pitanje za razmišljanje). Sledeći dan se otključava sutradan (ili odmah, uz opciju „Bez čekanja“ u Profilu).
- **Mira** – AI saputnica (Google Gemini) koja zna tvoje odgovore iz kviza, napredak i poslednja raspoloženja.
- **Dnevnik** – kalendar raspoloženja (emocije, okidači, beleška) i beleške sa pitanjima.
- **Profil** – statistika, grafikon raspoloženja, ponovna procena, podešavanja, pomoć u krizi, brisanje podataka.

Svi tekstovi su na srpskom (latinica) i prilagođeni rodu (`{muški|ženski}` šabloni, `lib/utils/sr.dart`).
Podaci se čuvaju lokalno (`shared_preferences`).

## Pokretanje

```bash
flutter pub get
flutter run                 # Android telefon/emulator
flutter run -d chrome       # Web
```

### Gemini API ključ (za Miru)

Napravi besplatan ključ na <https://aistudio.google.com> → „Get API key“, pa ga unesi u aplikaciji: **Profil → Mira (AI)**.
Alternativno, prosledi ga pri pokretanju:

```bash
flutter run --dart-define=GEMINI_API_KEY=tvoj_kljuc
```

Model se menja u istom ekranu (podrazumevano `gemini-3.8-flash`) ili sa `--dart-define=GEMINI_MODEL=...`.

### Svoje fotografije na početnom ekranu

Stavi `male.jpg` i `female.jpg` u `assets/images/` – umesto ilustracija prikazaće se fotografije.

## Struktura

```
lib/
  data/        sadržaj: kviz, 28 dana, kursevi, raspoloženja, pitanja za dnevnik
  models/      modeli podataka (JSON)
  providers/   Riverpod stanje + čuvanje
  services/    bodovanje kviza, Gemini klijent, kontekst za Miru
  screens/     ekrani (onboarding/ = kviz)
  widgets/     zajedničke komponente
```

## Napomena

Aplikacija nije zamena za stručnu pomoć. Procena iz kviza je orijentaciona i nije dijagnoza.
