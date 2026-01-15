'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"app-ads.txt": "21ea4cfe295b9fc6a0cbd914707bef21",
"assets/AssetManifest.bin": "7ab7b042e7e65f7856a376b1ebde71c3",
"assets/AssetManifest.bin.json": "5e3dce47fc951b219818ff77e0c1b907",
"assets/AssetManifest.json": "9083fcd629274bec1ec38799c1b4ee1d",
"assets/assets/icon/app_icon.png": "bac36ab5a5ca5ed5b2e0e18e173b1b0a",
"assets/assets/icon/app_icon_animated.gif": "7aa26620dd0dea4b9d9302f02fa9b820",
"assets/assets/icon/app_icon_splash.png": "316bc209e37466435f5ae39db1265600",
"assets/FontManifest.json": "c75f7af11fb9919e042ad2ee704db319",
"assets/fonts/MaterialIcons-Regular.otf": "f09f431a7c262fae8226c827bd4ad435",
"assets/lib/l10n/intl_en_US.json": "9f517b4b774536d84239605c680a74b8",
"assets/lib/l10n/intl_it_IT.json": "3bf2889910fe9594b2ea4f3fff6dbb6b",
"assets/NOTICES": "25a9228414b5876aab76df8320bcc5d8",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "15d54d142da2f2d6f2e90ed1d55121af",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "ec5353c1bc4a9f5a13c72371bbe0efe6",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "9120f6c5666818a697bab2be2a963b45",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf": "1fcba7a59e49001aa1b4409a25d425b0",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf": "c3317ecc6282b26790e88d377e4b5735",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf": "954c12bd779efbee0609f5ebd9b6524e",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"count_download.php": "92ef5ceadb35cf0f6d56763de1f43fe6",
"favicon.png": "c376da330b876415d2173d39b4edf823",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "5ad46222be132801956f0a47991166bc",
"icons/Icon-192.png": "11dc074cb2efd9bb87e4b6b1683e23df",
"icons/Icon-512.png": "995ac44b3216c90d70acab0b3f0d4113",
"icons/Icon-maskable-192.png": "11dc074cb2efd9bb87e4b6b1683e23df",
"icons/Icon-maskable-512.png": "995ac44b3216c90d70acab0b3f0d4113",
"index.html": "5e9719f92bf99682b184229ba73238ce",
"/": "5e9719f92bf99682b184229ba73238ce",
"insert_feedback.php": "d1a503c360811bd7a1f960e6b6f467f4",
"main.dart.js": "5999415b8bc1ceb596b6a54592b18dc2",
"manifest.json": "12c9c7f4f3882fe630558f968ec5209b",
"splash/img/dark-1x.gif": "d4e523fb895e5cbf11b68f42fdaebc9b",
"splash/img/dark-1x.png": "172ee15fa275adc3c4a50acb000080ae",
"splash/img/dark-2x.gif": "3b98778d320a8e0ae8807dfde3bb5d36",
"splash/img/dark-2x.png": "f2a5be4c7b416a021b6fe3210db01048",
"splash/img/dark-3x.gif": "e5737e61060a156b26ef1b7509b46708",
"splash/img/dark-3x.png": "008245854abf4be7c75134b37cc1bf60",
"splash/img/dark-4x.gif": "12ce7f4cca9e5cfe3e524c74b41ee510",
"splash/img/dark-4x.png": "9c49dcd7ece73ab29a24c5f71afad55e",
"splash/img/light-1x.gif": "d4e523fb895e5cbf11b68f42fdaebc9b",
"splash/img/light-1x.png": "172ee15fa275adc3c4a50acb000080ae",
"splash/img/light-2x.gif": "3b98778d320a8e0ae8807dfde3bb5d36",
"splash/img/light-2x.png": "f2a5be4c7b416a021b6fe3210db01048",
"splash/img/light-3x.gif": "e5737e61060a156b26ef1b7509b46708",
"splash/img/light-3x.png": "008245854abf4be7c75134b37cc1bf60",
"splash/img/light-4x.gif": "12ce7f4cca9e5cfe3e524c74b41ee510",
"splash/img/light-4x.png": "9c49dcd7ece73ab29a24c5f71afad55e",
"studycards.apk": "f86c3b0de3f1299d9fc2771d2b6fdfc2",
"studycards.ipa": "69d5245a134a1ecb3e9c292855ead519",
"studycards.zip": "a45acec1aff96fd22999c1a0c41aeffb",
"version.json": "e4b40e2a013aca82a7a69f2f98e021a1"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
