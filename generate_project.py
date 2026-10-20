import os
import uuid

def gen_id():
    return uuid.uuid4().hex[:24].upper()

project_dir = os.path.abspath(".")
app_dir = os.path.join(project_dir, "WordCube3D")
tests_dir = os.path.join(project_dir, "WordCube3DTests")

# Source files for App
app_sources = [
    "App/WordCube3DApp.swift",
    "Architecture/Effect.swift",
    "Architecture/Store.swift",
    "Models/Coordinate3D.swift",
    "Models/CubeBlock.swift",
    "Models/FoundWord.swift",
    "Models/GameTheme.swift",
    "State/GameState.swift",
    "State/GameAction.swift",
    "State/GameEnvironment.swift",
    "State/GameReducer.swift",
    "Services/DictionaryService.swift",
    "Services/HapticService.swift",
    "Services/SoundService.swift",
    "Services/PersistenceService.swift",
    "SceneKit/BlockTextureGenerator.swift",
    "SceneKit/CubeNode.swift",
    "SceneKit/ChainConnectionRenderer.swift",
    "SceneKit/CubeSceneRenderer.swift",
    "SceneKit/WordCubeSCNView.swift",
    "Views/GameView.swift",
    "Views/Components/LetterTileView.swift",
    "Views/Components/GlassCard.swift",
    "Views/Components/CircularTimerProgress.swift",
    "Views/HUD/ComboMultiplierBadge.swift",
    "Views/HUD/TopHUDBar.swift",
    "Views/HUD/WordChainTray.swift",
    "Views/HUD/FloatingBannerView.swift",
    "Views/Overlays/GameOverModal.swift",
    "Views/Overlays/WordHistorySheet.swift",
    "Views/Overlays/SettingsSheet.swift",
]

# Resources for App
app_resources = [
    "Resources/Assets.xcassets",
    "Resources/words_common.txt",
]

# Test sources
test_sources = [
    "WordCube3DTests.swift",
    "ReducerTests.swift",
]

# IDs
proj_id = gen_id()
main_group_id = gen_id()
app_group_id = gen_id()
tests_group_id = gen_id()
products_group_id = gen_id()

app_target_id = gen_id()
tests_target_id = gen_id()

app_product_id = gen_id()
tests_product_id = gen_id()

app_sources_build_phase_id = gen_id()
app_frameworks_build_phase_id = gen_id()
app_resources_build_phase_id = gen_id()

tests_sources_build_phase_id = gen_id()
tests_frameworks_build_phase_id = gen_id()
tests_resources_build_phase_id = gen_id()

target_proxy_id = gen_id()
target_dep_id = gen_id()

app_config_list_id = gen_id()
tests_config_list_id = gen_id()
proj_config_list_id = gen_id()

proj_debug_config_id = gen_id()
proj_release_config_id = gen_id()
app_debug_config_id = gen_id()
app_release_config_id = gen_id()
tests_debug_config_id = gen_id()
tests_release_config_id = gen_id()

build_files = []
file_refs = []
app_build_file_ids = []
app_res_file_ids = []
app_file_ref_ids = []
tests_build_file_ids = []
tests_file_ref_ids = []

for s in app_sources:
    bf_id = gen_id()
    fr_id = gen_id()
    name = os.path.basename(s)
    build_files.append(f'\t\t{bf_id} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fr_id} /* {name} */; }};')
    file_refs.append(f'\t\t{fr_id} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{s}"; sourceTree = "<group>"; }};')
    app_build_file_ids.append(bf_id)
    app_file_ref_ids.append(fr_id)

for r in app_resources:
    bf_id = gen_id()
    fr_id = gen_id()
    name = os.path.basename(r)
    file_type = "folder.assetcatalog" if r.endswith(".xcassets") else "text"
    build_files.append(f'\t\t{bf_id} /* {name} in Resources */ = {{isa = PBXBuildFile; fileRef = {fr_id} /* {name} */; }};')
    file_refs.append(f'\t\t{fr_id} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = {file_type}; path = "{r}"; sourceTree = "<group>"; }};')
    app_res_file_ids.append(bf_id)
    app_file_ref_ids.append(fr_id)

info_plist_id = gen_id()
file_refs.append(f'\t\t{info_plist_id} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "App/Info.plist"; sourceTree = "<group>"; }};')
app_file_ref_ids.append(info_plist_id)

for t in test_sources:
    bf_id = gen_id()
    fr_id = gen_id()
    name = os.path.basename(t)
    build_files.append(f'\t\t{bf_id} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fr_id} /* {name} */; }};')
    file_refs.append(f'\t\t{fr_id} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{t}"; sourceTree = "<group>"; }};')
    tests_build_file_ids.append(bf_id)
    tests_file_ref_ids.append(fr_id)

# Product references
file_refs.append(f'\t\t{app_product_id} /* WordCube3D.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = WordCube3D.app; sourceTree = BUILT_PRODUCTS_DIR; }};')
file_refs.append(f'\t\t{tests_product_id} /* WordCube3DTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = WordCube3DTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};')

build_files_str = "\n".join(build_files)
file_refs_str = "\n".join(file_refs)
app_children_str = "\n".join([f'\t\t\t\t{fid},' for fid in app_file_ref_ids])
tests_children_str = "\n".join([f'\t\t\t\t{fid},' for fid in tests_file_ref_ids])
app_res_files_str = "\n".join([f'\t\t\t\t{bfid} /* in Resources */,' for bfid in app_res_file_ids])
app_src_files_str = "\n".join([f'\t\t\t\t{bfid} /* in Sources */,' for bfid in app_build_file_ids])
tests_src_files_str = "\n".join([f'\t\t\t\t{bfid} /* in Sources */,' for bfid in tests_build_file_ids])

pbxproj = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
{build_files_str}
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
		{target_proxy_id} /* PBXContainerItemProxy */ = {{
			isa = PBXContainerItemProxy;
			containerPortal = {proj_id} /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = {app_target_id};
			remoteInfo = WordCube3D;
		}};
/* End PBXContainerItemProxy section */

/* Begin PBXFileReference section */
{file_refs_str}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{app_frameworks_build_phase_id} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{tests_frameworks_build_phase_id} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		{main_group_id} = {{
			isa = PBXGroup;
			children = (
				{app_group_id} /* WordCube3D */,
				{tests_group_id} /* WordCube3DTests */,
				{products_group_id} /* Products */,
			);
			sourceTree = "<group>";
		}};
		{app_group_id} /* WordCube3D */ = {{
			isa = PBXGroup;
			children = (
{app_children_str}
			);
			path = WordCube3D;
			sourceTree = "<group>";
		}};
		{tests_group_id} /* WordCube3DTests */ = {{
			isa = PBXGroup;
			children = (
{tests_children_str}
			);
			path = WordCube3DTests;
			sourceTree = "<group>";
		}};
		{products_group_id} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{app_product_id} /* WordCube3D.app */,
				{tests_product_id} /* WordCube3DTests.xctest */,
			);
			name = Products;
			sourceTree = "<group>";
		}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{app_target_id} /* WordCube3D */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {app_config_list_id} /* Build configuration list for PBXNativeTarget "WordCube3D" */;
			buildPhases = (
				{app_sources_build_phase_id} /* Sources */,
				{app_frameworks_build_phase_id} /* Frameworks */,
				{app_resources_build_phase_id} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = WordCube3D;
			productName = WordCube3D;
			productReference = {app_product_id} /* WordCube3D.app */;
			productType = "com.apple.product-type.application";
		}};
		{tests_target_id} /* WordCube3DTests */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {tests_config_list_id} /* Build configuration list for PBXNativeTarget "WordCube3DTests" */;
			buildPhases = (
				{tests_sources_build_phase_id} /* Sources */,
				{tests_frameworks_build_phase_id} /* Frameworks */,
				{tests_resources_build_phase_id} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
				{target_dep_id} /* PBXTargetDependency */,
			);
			name = WordCube3DTests;
			productName = WordCube3DTests;
			productReference = {tests_product_id} /* WordCube3DTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{proj_id} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1600;
				LastUpgradeCheck = 1600;
				TargetAttributes = {{
					{app_target_id} = {{
						CreatedOnToolsVersion = 16.0;
					}};
					{tests_target_id} = {{
						CreatedOnToolsVersion = 16.0;
						TestTargetID = {app_target_id};
					}};
				}};
			}};
			buildConfigurationList = {proj_config_list_id} /* Build configuration list for PBXProject "WordCube3D" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {main_group_id};
			productRefGroup = {products_group_id} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{app_target_id} /* WordCube3D */,
				{tests_target_id} /* WordCube3DTests */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{app_resources_build_phase_id} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{app_res_files_str}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{tests_resources_build_phase_id} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{app_sources_build_phase_id} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{app_src_files_str}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{tests_sources_build_phase_id} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{tests_src_files_str}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
		{target_dep_id} /* PBXTargetDependency */ = {{
			isa = PBXTargetDependency;
			target = {app_target_id} /* WordCube3D */;
			targetProxy = {target_proxy_id} /* PBXContainerItemProxy */;
		}};
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
		{proj_debug_config_id} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			}};
			name = Debug;
		}};
		{proj_release_config_id} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				VALIDATE_PRODUCT = YES;
			}};
			name = Release;
		}};
		{app_debug_config_id} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = NO;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEFINES_MODULE = YES;
				DEVELOPMENT_ASSET_PATHS = "";
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = WordCube3D/App/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = "WordCube 3D";
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.word-games";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.wordcube.WordCube3D;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{app_release_config_id} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = NO;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEFINES_MODULE = YES;
				DEVELOPMENT_ASSET_PATHS = "";
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = WordCube3D/App/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = "WordCube 3D";
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.word-games";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.wordcube.WordCube3D;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
		{tests_debug_config_id} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES;
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.wordcube.WordCube3DTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/WordCube3D.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/WordCube3D";
			}};
			name = Debug;
		}};
		{tests_release_config_id} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES;
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.wordcube.WordCube3DTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/WordCube3D.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/WordCube3D";
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{proj_config_list_id} /* Build configuration list for PBXProject "WordCube3D" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{proj_debug_config_id} /* Debug */,
				{proj_release_config_id} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{app_config_list_id} /* Build configuration list for PBXNativeTarget "WordCube3D" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{app_debug_config_id} /* Debug */,
				{app_release_config_id} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{tests_config_list_id} /* Build configuration list for PBXNativeTarget "WordCube3DTests" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{tests_debug_config_id} /* Debug */,
				{tests_release_config_id} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */

	}};
	rootObject = {proj_id} /* Project object */;
}}
"""

os.makedirs(os.path.join(project_dir, "WordCube3D.xcodeproj"), exist_ok=True)
pbxproj_path = os.path.join(project_dir, "WordCube3D.xcodeproj", "project.pbxproj")
with open(pbxproj_path, "w") as f:
    f.write(pbxproj)

# Generate Shared Scheme
scheme = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{app_target_id}"
               BuildableName = "WordCube3D.app"
               BlueprintName = "WordCube3D"
               ReferencedContainer = "container:WordCube3D.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "NO"
            buildForProfiling = "NO"
            buildForArchiving = "NO"
            buildForAnalyzing = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{tests_target_id}"
               BuildableName = "WordCube3DTests.xctest"
               BlueprintName = "WordCube3DTests"
               ReferencedContainer = "container:WordCube3D.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{tests_target_id}"
               BuildableName = "WordCube3DTests.xctest"
               BlueprintName = "WordCube3DTests"
               ReferencedContainer = "container:WordCube3D.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_id}"
            BuildableName = "WordCube3D.app"
            BlueprintName = "WordCube3D"
            ReferencedContainer = "container:WordCube3D.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_id}"
            BuildableName = "WordCube3D.app"
            BlueprintName = "WordCube3D"
            ReferencedContainer = "container:WordCube3D.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""

schemes_dir = os.path.join(project_dir, "WordCube3D.xcodeproj", "xcshareddata", "xcschemes")
os.makedirs(schemes_dir, exist_ok=True)
with open(os.path.join(schemes_dir, "WordCube3D.xcscheme"), "w") as f:
    f.write(scheme)

print("Successfully generated WordCube3D.xcodeproj and scheme without asset symbol generation!")
