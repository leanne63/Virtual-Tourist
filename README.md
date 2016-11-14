# Virtual-Tourist
UI Flow for app (iPhone 6 Simulator):

1) The app opens, displaying a map.

![map for placing pins](README_images/VirtualTourist_1-Map.png "Map for placing pins in the areas where you'd like to get publicly available Flickr photos.")


2) Zoom to an area where you'd like to place a pin, then long press the desired location.

![zoomed map view](README_images/VirtualTourist_2-PlacePin.png "Zoomed map view with pin in place.")


3) Tapping the pin segues to the "album" view, where photos begin loading.

![user tapped pin](README_images/3_MapViewWSearchText.png "Map segues to album view, showing photos loading.")

![waiting for photos to load](README_images/VirtualTourist_3a-LoadingProgress.png "Activity indicators reflect ongoing downloads, and New Collection button is disabled.")


4) Up to 10 images will display upon download completion. Tap the New Collection button to replace the existing images with a new set.

![album view with all photos downloaded](README_images/VirtualTourist_4-PhotosLoaded.png "Album view showing up to 10 results for pin location.")

Note: pins and up to 10 associated photos are persistently stored in Core Data. Requesting a New Collection replaces any existing photos in the underlying database with a new set of results from Flickr for the selected location.

The app currently doesn't have a delete function coded. If you desire to remove pins and photos to start with a clean slate:
- if using a simulator, click on Simulator/Reset Contents and Settings...
- if running on a device, delete the app from the device.

