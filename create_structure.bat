@echo off
setlocal enabledelayedexpansion

echo Creating folder and file structure inside current Flutter project...

rem Define folders
set folders=^
lib\config ^
lib\models ^
lib\services ^
lib\providers ^
lib\screens\onboarding ^
lib\screens\home ^
lib\screens\location ^
lib\screens\review ^
lib\screens\profile ^
lib\screens\geoquest ^
lib\screens\leaderboard ^
lib\widgets\common ^
lib\widgets\location ^
lib\widgets\review ^
lib\widgets\profile ^
lib\utils ^
assets\images ^
assets\icons ^
assets\animations

for %%f in (%folders%) do (
    mkdir "%%f" 2>nul
)

rem Define files
set files=^
lib\main.dart ^
lib\config\theme.dart ^
lib\config\constants.dart ^
lib\models\location_model.dart ^
lib\models\review_model.dart ^
lib\models\user_model.dart ^
lib\models\geoquest_model.dart ^
lib\services\web3_service.dart ^
lib\services\supabase_service.dart ^
lib\services\storage_service.dart ^
lib\services\location_service.dart ^
lib\services\wallet_service.dart ^
lib\providers\auth_provider.dart ^
lib\providers\location_provider.dart ^
lib\providers\review_provider.dart ^
lib\providers\user_provider.dart ^
lib\screens\onboarding\splash_screen.dart ^
lib\screens\onboarding\onboarding_screen.dart ^
lib\screens\onboarding\auth_screen.dart ^
lib\screens\home\home_screen.dart ^
lib\screens\home\map_view.dart ^
lib\screens\location\add_location_screen.dart ^
lib\screens\location\location_detail_screen.dart ^
lib\screens\location\verify_location_screen.dart ^
lib\screens\review\add_review_screen.dart ^
lib\screens\review\review_list_screen.dart ^
lib\screens\profile\profile_screen.dart ^
lib\screens\profile\wallet_screen.dart ^
lib\screens\geoquest\geoquest_screen.dart ^
lib\screens\leaderboard\leaderboard_screen.dart ^
lib\widgets\common\custom_button.dart ^
lib\widgets\common\custom_text_field.dart ^
lib\widgets\common\loading_overlay.dart ^
lib\widgets\common\responsive_builder.dart ^
lib\widgets\location\location_card.dart ^
lib\widgets\location\map_marker.dart ^
lib\widgets\review\review_card.dart ^
lib\widgets\profile\stat_card.dart ^
lib\widgets\profile\badge_widget.dart ^
lib\utils\validators.dart ^
lib\utils\helpers.dart ^
lib\utils\extensions.dart ^
.env.example ^
README.md

for %%f in (%files%) do (
    if not exist "%%f" (
        type nul > "%%f"
    )
)

echo.
echo ✅ Folder and file structure created successfully inside:
echo %cd%
pause
