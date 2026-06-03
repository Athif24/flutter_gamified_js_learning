# AGENTS.md — Panduan Responsive Scaling

Saat diminta melakukan responsive scaling pada suatu feature, lakukan audit
**menyeluruh** di SEMUA file terkait (termasuk widget, screen, skeleton) dengan
cek pola berikut:

## Checklist Wajib

- [ ] `BorderRadius.circular(X)` / `Radius.circular(X)` — ganti `S.scale(context, X)`
- [ ] `Border.all(width: X)` atau `border.width` — ganti `S.scale(context, X)`
- [ ] `Offset(X,Y)` di BoxShadow — ganti `Offset(S.scale(context, X), S.scale(context, Y))`
- [ ] `EdgeInsets` dengan hardcoded angka — ganti `S.scale(context, X)`
- [ ] `const SizedBox(height/width: X)` sebagai spacer layout — ganti `SizedBox(height: S.scale(context, X))`
- [ ] `SizedBox` / `Container` dengan hardcoded width/height > 0 — ganti `S.scale(context, X)`
- [ ] `Icon(size: X)` — ganti `S.scale(context, X)`
- [ ] `letterSpacing: X` — ganti `S.scale(context, X)`
- [ ] `strokeWidth`, `dash`, `gap` di CustomPainter — parameterized + dikirim `S.scale`
- [ ] `blurRadius` / `spreadRadius` di BoxShadow — ganti `S.scale(context, X)`
- [ ] `Divider(height: X)` / `Divider(thickness: X)` — ganti `S.scale(context, X)`
- [ ] `spacing` / `runSpacing` di GridView/Wrap — ganti `S.scale(context, X)`
- [ ] `Text` dinamis (formatNumber, user-generated) tanpa `FittedBox` — wrapping
- [ ] Pastikan `import '...responsive_utils.dart'` ada di setiap file

## Format Respons

Untuk setiap feature, kembalikan:

1. Daftar file + baris + nilai hardcoded yang ditemukan
2. Severity (CRITICAL / HIGH / MEDIUM)
3. Usulan grup commit

## ✅ DONE — Collapse HeaderCard vs Tutorial Highlight

**Masalah:** HeaderCard punya tombol ▲/▼ (expand/collapse) dengan internal setState.
Saat user menekan tombol saat tutorial step 1, highlight tidak menyesuaikan ukuran card.

**Solusi:** State expand/collapse dipindahkan ke parent (CourseDetailScreen).

**File yang diubah:**

| File | Perubahan |
|:-----|:----------|
| `header_card.dart` | `StatefulWidget` → `StatelessWidget`. Hapus `_isExpanded`. Tambah: `final bool isExpanded; final VoidCallback onToggle;`. Fix `widget.` → field langsung. |
| `course_detail_screen.dart` | Tambah `bool _isCardExpanded = true`. Pass `isExpanded` + `setState` di `onToggle` ke HeaderCard. |
