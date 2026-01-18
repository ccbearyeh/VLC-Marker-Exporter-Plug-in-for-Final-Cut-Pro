# VLC-Marker-Exporter-Plug-in-for-Final-Cut-Pro
A Lua extension for VLC Media Player that allows video reviewers to add timestamped markers with notes during playback and export them for editing workflows.

Designed to streamline the feedback loop between reviewers (using VLC) and editors (using Final Cut Pro), eliminating the need for paid collaboration platforms like Frame.io for simple marking tasks.

### Developed with assistance from Perplexity AI.

## Features
- Add Markers During Playback: Click "Add Marker" to timestamp the current frame instantly.
- Categorized Notes: Select note types (Cut, Add, Audio, Color, Text, etc.) and add detailed descriptions.
- Live Marker List: View all added markers directly in the VLC interface.
- Export to CSV: Generates a structured CSV file compatible with editing tools and converters.
- Cross-Platform: Works on both macOS and Windows versions of VLC.

## Installation
### macOS
1. Download 'marker_export.lua'.
2. Move the file to the VLC extensions directory:
  '~/Library/Application Support/org.videolan.vlc/lua/extensions/'
  (Create the directory if it doesn't exist)
3. Restart VLC.

### Windows
1. Download 'marker_export.lua'.
2. Move the file to the VLC extensions directory:
   'C:\Users\%USERNAME%\AppData\Roaming\vlc\lua\extensions\'
   (Create the directory if it doesn't exist)
3. Restart VLC.

## Usage Guide
1. Adding Markers
  1. Open a video in VLC.
  2. Go to the menu bar: **VLC -> Extensions -> Marker Export for FCP**.
  3. When you spot an edit point, pause the video (optional) and click **Add Marker**.
  4. In the dialog:
    - Verify the Timecode.
    - Select a **Note Type** (e.g., "Cut", "Audio", "Color").
    - Enter your **Description**.
    - Click **Save Marker**. 
2. Exporting & Workflow
  1. Once finished, click **Export CSV**.
  2. Save the CSV file to your desktop.
  3. **Import to Final Cut Pro**:
    - Use a free tool like **[EditingTools.io Marker Converter](https://editingtools.io/marker/)** to convert the CSV to '.fcpxml'.
    - Drag the generated '.fcpxml' file directly onto your Final Cut Pro timeline (or import it as an event).
    - Alternatively, use the CSV with the 'Marker Toolbox' app on macOS. 
## CSV Format
The exported CSV follows a standard editing note structure:
'''
Timecode, In TC, Out TC, Note Type, Description, Priority, Status, Reference
00:01:23:10,,,Cut,"Remove this section",Medium,Pending,
'''
## Credits
- Concept & Code Structure: Shawn Yeh
- AI Assistance & Lua Scripting: Perplexity AI
