FLUTTER := fvm flutter
DART    := fvm dart

.PHONY: get gen l10n watch clean analyze test format run-dev run-stg run-prod apk-dev apk-prod ipa-prod

get:        ; $(FLUTTER) pub get
l10n:       ; $(DART) run intl_utils:generate
gen: l10n   ; $(DART) run build_runner build -d
watch:      ; $(DART) run build_runner watch -d
clean:      ; $(FLUTTER) clean && $(FLUTTER) pub get
analyze:    ; $(FLUTTER) analyze
format:     ; $(DART) format lib test
test:       ; $(FLUTTER) test

run-dev:    ; $(FLUTTER) run --flavor dev  -t lib/main_dev.dart
run-stg:    ; $(FLUTTER) run --flavor stg  -t lib/main_stg.dart
run-prod:   ; $(FLUTTER) run --flavor prod -t lib/main_prod.dart

apk-dev:    ; $(FLUTTER) build apk --flavor dev  -t lib/main_dev.dart
apk-prod:   ; $(FLUTTER) build apk --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols
ipa-prod:   ; $(FLUTTER) build ipa --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols
