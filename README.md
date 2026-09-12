# Fluenary

Base Flutter app (mobile only: Android + iOS) dùng **Flutter 3.47.0 / Dart 3.13**, kiến trúc feature-first với Bloc/Cubit, 3 flavor `dev` / `stg` / `prod`.

Mục tiêu: clone ra dự án mới trong vài phút — mọi thứ cross-cutting (env, network, DI, logging, theme, i18n, router, error handling) đã được wiring sẵn.

## Stack

| Lớp | Package | Ghi chú |
|---|---|---|
| Version pin | [FVM](https://fvm.app) (`.fvmrc`) | Luôn dùng `fvm flutter` / `fvm dart` |
| State | `flutter_bloc`, `bloc`, `equatable` | Cubit cho feature đơn giản, Bloc cho feature phức tạp |
| DI | `get_it` | Đăng ký thủ công trong `lib/core/di/injection.dart` |
| Navigation | `go_router` | Route name tập trung ở `lib/app/router/routes.dart` |
| Network | `dio` | Interceptor auth + log (Talker) |
| Env / flavor | `envied`, `flutter_flavorizr` | Config đọc từ `env/.env.<flavor>`, obfuscate khi build |
| Models | `freezed`, `json_serializable` | DTO ở tầng data, Entity ở tầng domain |
| Storage | `shared_preferences`, `flutter_secure_storage` | Gom vào `AppStorage` |
| i18n | `flutter_intl` / `intl_utils` | ARB tại `lib/l10n/`, class `S` sinh ra ở `lib/generated/` |
| Logging | `talker`, `talker_flutter`, `talker_dio_logger`, `talker_bloc_logger` | Có màn hình xem log trong app (`/logs`) |
| Test | `bloc_test`, `mocktail` | |

## Yêu cầu

- [FVM](https://fvm.app/documentation/getting-started/installation) ≥ 4.x
- Xcode + CocoaPods (iOS), Android Studio / JDK 17+ (Android)
- `make` (có sẵn trên macOS)

## Bắt đầu

```bash
# 1. Cài đúng Flutter version theo .fvmrc
fvm install

# 2. Tạo env files từ mẫu (chỉ *.example được commit)
cp env/.env.dev.example  env/.env.dev
cp env/.env.stg.example  env/.env.stg
cp env/.env.prod.example env/.env.prod

# 3. Lấy dependency + sinh code (envied, freezed, json, l10n)
make get
make gen

# 4. Chạy flavor dev
make run-dev
```

Trong VS Code: mở Run panel, chọn cấu hình `dev` / `stg` / `prod` (đã có trong `.vscode/launch.json`).
Trong Android Studio: chọn run configuration tương ứng (flavorizr đã tạo trong `.idea/`).

## Lệnh thường dùng (Makefile)

| Lệnh | Tác dụng |
|---|---|
| `make get` | `flutter pub get` |
| `make gen` | Sinh l10n rồi chạy `build_runner build` (envied, freezed, json) |
| `make watch` | `build_runner watch` — tự sinh khi sửa file |
| `make l10n` | Chỉ sinh lại localization từ ARB |
| `make analyze` / `make format` / `make test` | Lint, format, test |
| `make run-dev` / `run-stg` / `run-prod` | Chạy app theo flavor |
| `make apk-dev` / `apk-prod` | Build APK (prod có obfuscate + split-debug-info) |
| `make ipa-prod` | Build IPA prod |
| `make clean` | `flutter clean` + `pub get` |

Chạy tay không qua Makefile:

```bash
# Sinh code (envied, freezed, json_serializable) — tương đương `make gen` (không gồm l10n)
fvm dart run build_runner build --delete-conflicting-outputs
```

```bash
# Sinh localization từ ARB
fvm dart run intl_utils:generate
```

```bash
fvm flutter run --flavor dev -t lib/main_dev.dart
```

> Flavor và entry point phải khớp nhau: `--flavor dev` ↔ `lib/main_dev.dart`.

## Cấu trúc thư mục

```
lib/
├── main_dev.dart / main_stg.dart / main_prod.dart   # entry point từng flavor
├── bootstrap.dart            # init chung: DI, error zone, Bloc observer, runApp
├── app/
│   ├── app.dart              # MaterialApp.router + Bloc toàn app (ThemeCubit, ...)
│   ├── router/               # go_router config (app_router.dart) + tên route (routes.dart)
│   └── theme/                # AppTheme (Material 3) + AppColors (ThemeExtension)
├── core/
│   ├── env/                  # AppEnv (abstract) + EnvDev/EnvStg/EnvProd (envied)
│   ├── di/                   # get_it: configureDependencies()
│   ├── auth/                 # TokenManager (refresh lock, proactive/reactive), Jwt decode
│   ├── network/              # createPlainDio() / createAuthedDio(), AuthInterceptor
│   ├── storage/              # AppStorage (prefs + secure storage)
│   ├── error/                # Failure (sealed), Result<T> (sealed), guard()
│   ├── logger/               # AppLogger (Talker wrapper)
│   ├── utils/                # extensions (context.l10n, context.colors, ...)
│   └── widgets/              # AppLoading, AppErrorView, ...
├── features/
│   ├── auth/                 # login/logout, AuthCubit (guard router), mock datasource sinh JWT giả
│   ├── home/                 # ví dụ feature ĐƠN GIẢN: chỉ cubit + screen
│   ├── settings/             # ThemeCubit (persist qua AppStorage)
│   └── example/              # ví dụ feature PHỨC TẠP: Clean Architecture đầy đủ
│       ├── data/             # datasources, models (DTO freezed), repositories impl
│       ├── domain/           # entities, repositories (abstract), usecases
│       └── presentation/     # bloc (event/state/bloc), screens, widgets
├── l10n/                     # intl_vi.arb (nguồn)
└── generated/                # l10n sinh ra — KHÔNG commit, không sửa tay

env/                          # .env.<flavor> (gitignored) + .env.<flavor>.example
test/                         # mirror cấu trúc lib/
```

### Quy ước kiến trúc

- **Feature-first**: mỗi feature tự chứa data/domain/presentation. Xóa thư mục feature + xóa đăng ký trong `injection.dart` và `app_router.dart` là gỡ sạch.
- **Clean Architecture có chọn lọc**:
  - Feature đơn giản (form, màn hình tĩnh, counter…): chỉ `presentation/` với Cubit + Screen. Xem `features/home`.
  - Feature phức tạp (gọi API, nhiều rule nghiệp vụ, cần test kỹ): đủ 3 tầng. Xem `features/example`.
- **Cubit vs Bloc**: Cubit khi state thay đổi bằng lời gọi hàm trực tiếp; Bloc khi cần event stream, debounce/throttle, hoặc nhiều event tác động cùng state.
- **Không `try/catch` ở Bloc**: repository trả `Result<T>` (`Success` | `Error`) qua `guard()`, Bloc `switch` trên kết quả.
- **Không dùng `BuildContext` ngoài widget**: Bloc/usecase/repository chỉ nhận dependency qua constructor (từ `getIt`).

## Flavor & Env

### Cách hoạt động

```
env/.env.dev  ──envied──▶  lib/core/env/env_dev.g.dart  ──▶  EnvDev  ──▶  bootstrap(EnvDev())
                                                                              └─ getIt<AppEnv>()
```

- Mỗi flavor có một file `env/.env.<flavor>` và một class `Env<Flavor>` implement `AppEnv`.
- Giá trị được **obfuscate** vào binary lúc build (`@Envied(obfuscate: true)`), không đọc file lúc runtime.
- Lấy config ở bất kỳ đâu: `getIt<AppEnv>().apiBaseUrl`.

### Thêm biến env mới

1. Thêm dòng vào cả 3 file `env/.env.*` **và** 3 file `.example`.
2. Thêm getter vào `AppEnv` (`lib/core/env/app_env.dart`).
3. Thêm `@EnviedField` vào `EnvDev`, `EnvStg`, `EnvProd`.
4. `make gen`.

### Bundle ID / App name

| Flavor | Android applicationId | iOS bundleId | Tên app |
|---|---|---|---|
| dev | `com.phipham.fluenary.dev` | `com.phipham.fluenary.dev` | Fluenary Dev |
| stg | `com.phipham.fluenary.stg` | `com.phipham.fluenary.stg` | Fluenary Stg |
| prod | `com.phipham.fluenary` | `com.phipham.fluenary` | Fluenary |

Cấu hình gốc nằm ở block `flavorizr:` trong `pubspec.yaml`. Nếu đổi tên/bundle id hoặc thêm flavor, sửa block đó rồi chạy:

```bash
fvm dart run flutter_flavorizr -f
```

Flavorizr sinh: `android/app/flavorizr.gradle.kts`, `ios/Flutter/<flavor><Config>.xcconfig`, scheme Xcode `dev`/`stg`/`prod`, và `ios/Podfile` với 9 configuration. **Không sửa tay các file này.**

## Localization

- Nguồn: `lib/l10n/intl_vi.arb` (locale chính `vi`). Thêm ngôn ngữ mới: tạo `intl_en.arb` cùng key.
- Sinh code: `make l10n` (hoặc IDE plugin *Flutter Intl* tự sinh khi save ARB).
- Dùng trong widget: `context.l10n.home` (extension ở `core/utils/context_ext.dart`).
- Placeholder:

```json
"counter": "Bạn đã nhấn {count} lần",
"@counter": {"placeholders": {"count": {"type": "int"}}}
```

→ `context.l10n.counter(3)`.

## Networking

- Có **2 Dio** trong DI (`core/network/dio_client.dart`):
  - `getIt<Dio>()` — Dio chính, có `AuthInterceptor`. Dùng cho mọi API nghiệp vụ.
  - `getIt<Dio>(instanceName: plainDio)` — Dio "trần", không interceptor auth. Chỉ dùng cho login/refresh để tránh vòng lặp.
- `baseUrl`, timeout lấy từ env. Log request/response qua `TalkerDioLogger`, chỉ bật khi `ENABLE_LOG=true`.
- Request không cần token: `Options(extra: {AuthInterceptor.noAuth: true})`.
- Lỗi được chuẩn hoá ở `core/error/failure.dart`:
  - `NetworkFailure` — timeout / mất mạng
  - `ServerFailure(statusCode, message)` — HTTP lỗi, `message` lấy từ `response.data['message']`
  - `UnknownFailure`

## Auth & Refresh token

### Luồng

```
                    ┌────────────── proactive ──────────────┐
request ──▶ AuthInterceptor.onRequest ──▶ TokenManager.validAccessToken()
                                             │ access sắp hết hạn (exp - 30s)? → refresh()
                                             ▼
                                        gắn Bearer ──▶ server
                                                          │ 401?
                                                          ▼
                    AuthInterceptor.onError ──▶ TokenManager.refresh() ──▶ retry request gốc (1 lần)
                                                     │
                                       ┌─────────────┴──────────────┐
                                  refresh OK                  refresh 401/403
                                  lưu token mới               xoá token + AuthEvent.sessionExpired
                                                                     │
                                                              AuthCubit → Unauthenticated
                                                              GoRouter.redirect → /login + snackbar
```

### Các quyết định thiết kế

| Vấn đề | Cách xử lý |
|---|---|
| N request 401 cùng lúc | `TokenManager.refresh()` lock bằng `Completer`: chỉ 1 request refresh thật, các caller khác chờ chung kết quả. Có test `5 lần refresh đồng thời chỉ gọi datasource 1 lần`. |
| Vòng lặp refresh → 401 → refresh | Login/refresh dùng Dio "trần" + `extra[noAuth]`; request đã retry được đánh dấu `extra[retried]`, không retry lần 2. |
| Refresh lỗi mạng | **Không logout.** `refresh()` ném `DioException`, request gốc fail như lỗi mạng bình thường. Chỉ 401/403 từ endpoint refresh mới coi là phiên hết hạn. |
| Proactive | Token là JWT → `Jwt.tryDecode` đọc `exp`. Nếu còn < 30s (`TokenManager.refreshLeeway`) thì refresh trước khi gửi. Không phải JWT → bỏ qua, chỉ dựa vào 401. |
| UI biết logout khi nào | `TokenManager.events` (stream) → `AuthCubit` → `GoRouter.refreshListenable` re-evaluate `redirect`. Interceptor không đụng UI. |
| App khởi động | `AuthCubit` bắt đầu ở `AuthUnknown`, router giữ ở `/splash` đến khi đọc xong storage. |

### Mock (hiện tại)

`AuthMockDataSource` không gọi mạng, tự sinh JWT giả (`alg: none`):

- Login: email/mật khẩu bất kỳ không rỗng → thành công.
- Access token TTL **1 phút**, refresh TTL 7 ngày, có rotate refresh token.
- Để test luồng refresh: đăng nhập, đợi > 1 phút, mở màn *Ví dụ* → interceptor tự refresh (xem log ở `/logs`).

Chuyển sang backend thật: đổi 1 dòng trong `injection.dart`

```dart
..registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSourceImpl(getIt(instanceName: plainDio)),
)
```

và chỉnh `_parse()` trong `AuthRemoteDataSourceImpl` theo shape response của server.

### Thêm màn hình cần đăng nhập

Mặc định **mọi route đều cần đăng nhập**, trừ những route trong `Routes.public`. Thêm route public thì thêm vào set đó.

## Logging

- `getIt<AppLogger>()` hoặc inject `AppLogger` vào constructor. Method: `d / i / w / e`.
- `Bloc.observer = TalkerBlocObserver` → mọi event/transition đều được log.
- `TalkerRouteObserver` log mọi navigation.
- Mở màn hình log trong app: route `/logs` (link ở Home). Tắt hoàn toàn ở prod bằng `ENABLE_LOG=false`.
- Crash reporter (Crashlytics/Sentry): hook vào `talker.handle` trong `bootstrap.dart`.

## Theme

- Material 3, `ColorScheme.fromSeed`. Đổi seed tại `AppTheme._seed`.
- Màu ngoài ColorScheme (success, warning…) khai báo trong `AppColors` (ThemeExtension), đọc bằng `context.appColors.success`.
- Light / Dark / System lưu qua `ThemeCubit` + `AppStorage`.

## Thêm một feature mới

**Feature đơn giản** (theo mẫu `home`):

```
features/<name>/presentation/
├── cubit/<name>_cubit.dart
└── screens/<name>_screen.dart
```

Thêm route vào `app_router.dart` + `routes.dart`. Xong.

**Feature phức tạp** (theo mẫu `example`):

1. `domain/entities/` — entity thuần (`Equatable`).
2. `domain/repositories/` — `abstract interface class XxxRepository`.
3. `domain/usecases/` — mỗi usecase một class có `call()`.
4. `data/models/` — DTO `@freezed` + `fromJson` + `toEntity()`.
5. `data/datasources/` — gọi Dio.
6. `data/repositories/` — implement repository, bọc bằng `guard()`.
7. `presentation/bloc/` — `sealed class` event/state, Bloc `switch` trên `Result`.
8. `presentation/screens/` — `BlocProvider` + `BlocBuilder` với `switch` trên state.
9. Đăng ký DI trong `core/di/injection.dart`, route trong `app/router/`.
10. Test bloc với `bloc_test` + `mocktail` (xem `test/features/example/`).

## Testing

```bash
make test
```

- Unit/Bloc test: mock usecase bằng `mocktail`, verify state sequence bằng `blocTest`.
- Widget test: bọc widget trong `MaterialApp` với `localizationsDelegates: [S.delegate, ...]` và `BlocProvider.value`.
- Cấu trúc `test/` mirror `lib/`.

## Lint

`analysis_options.yaml` dùng `flutter_lints` + vài rule bổ sung (`prefer_single_quotes`, `unawaited_futures`, `directives_ordering`…). File sinh (`*.g.dart`, `*.freezed.dart`, `lib/generated/`) được exclude.

```bash
make analyze
make format
```

## Lưu ý Flutter 3.47

- **Impeller** là renderer mặc định trên Android và iOS — không cần flag; test hiệu ứng blur/shader sớm.
- **Swift Package Manager** cho iOS bật mặc định; Podfile vẫn được giữ vì flavorizr cần và một số plugin chưa hỗ trợ SPM.
- `RadioListTile.groupValue` / `onChanged` đã deprecate → dùng `RadioGroup` (xem `settings_screen.dart`).
- Dart 3.13: dùng `sealed class` + `switch` expression thay cho union freezed cho state/event.

## Checklist trước khi release

- [ ] `env/.env.prod` đúng URL, `ENABLE_LOG=false`
- [ ] Đổi seed color / app icon / splash
- [ ] Ký app: `android/key.properties` + `ios` signing team
- [ ] `make apk-prod` / `make ipa-prod` (đã bật `--obfuscate --split-debug-info`)
- [ ] Gắn crash reporter vào `bootstrap.dart`
- [ ] Bỏ route `/logs` khỏi UI prod (hoặc guard bằng `env.isProd`)
- [ ] Thay `AuthMockDataSource` bằng `AuthRemoteDataSourceImpl`

## Files không commit

Xem `.gitignore`: `env/.env.*` (trừ `.example`), `*.g.dart`, `*.freezed.dart`, `lib/generated/`, `.fvm/`.
Sau khi clone luôn chạy `make gen` trước khi build.
