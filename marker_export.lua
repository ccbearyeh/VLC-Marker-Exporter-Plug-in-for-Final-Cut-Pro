-- Marker storage
markers = {}
dlg = nil

function descriptor()
    return {
        title = "Marker Export for FCP",
        version = "2.0",
        author = "Your Name",
        capabilities = {"menu"}
    }
end

function activate()
    vlc.msg.info("=== Marker Export for FCP activated ===")
    create_dialog()
end

function deactivate()
    vlc.msg.info("=== Deactivating ===")
    if dlg then
        dlg:delete()
        dlg = nil
    end
end

function close()
    vlc.msg.info("=== Close button clicked ===")
    deactivate()
end

function create_dialog()
    vlc.msg.info("Creating main dialog...")
    
    if dlg then
        dlg:delete()
        dlg = nil
    end
    
    dlg = vlc.dialog("Marker Export for FCP")
    
    local row = 1
    dlg:add_label("Click 'Add Marker' to mark current position.", 1, row, 2, 1)
    row = row + 1
    
    dlg:add_label("Total Markers: " .. #markers, 1, row, 2, 1)
    row = row + 1
    
    -- Show each marker as a separate label
    if #markers > 0 then
        dlg:add_label("─────────────────────────────", 1, row, 2, 1)
        row = row + 1
        
        for i, marker in ipairs(markers) do
            local marker_line = i .. ". " .. format_timecode(marker.time, 60) .. " - " .. marker.note
            dlg:add_label(marker_line, 1, row, 2, 1)
            row = row + 1
        end
        
        dlg:add_label("─────────────────────────────", 1, row, 2, 1)
        row = row + 1
    end
    
    dlg:add_button("Add Marker", add_marker, 1, row, 1, 1)
    dlg:add_button("Export CSV", export_csv, 2, row, 1, 1)
    row = row + 1
    
    dlg:add_button("Clear All", clear_markers, 1, row, 1, 1)
    dlg:add_button("Close", close, 2, row, 1, 1)
    
    vlc.msg.info("Main dialog created with " .. #markers .. " markers")
end

function add_marker()
    vlc.msg.info("=== Add Marker button clicked ===")
    
    local input = vlc.object.input()
    if not input then
        vlc.msg.warn("No video playing! Please start playing a video first.")
        return
    end
    
    local time = vlc.var.get(input, "time")
    local time_seconds = time / 1000000
    
    vlc.msg.info("Current time: " .. time_seconds .. " seconds")
    
    if dlg then
        dlg:delete()
        dlg = nil
    end
    
    local note_dlg = vlc.dialog("Add Marker at " .. format_timecode(time_seconds, 60))
    
    note_dlg:add_label("Timecode: " .. format_timecode(time_seconds, 60), 1, 1, 2, 1)
    note_dlg:add_label("Note Type:", 1, 2, 1, 1)
    
    local type_dropdown = note_dlg:add_dropdown(2, 2, 1, 1)
    type_dropdown:add_value("Cut", 1)
    type_dropdown:add_value("Add", 2)
    type_dropdown:add_value("Audio", 3)
    type_dropdown:add_value("Text", 4)
    type_dropdown:add_value("Color", 5)
    type_dropdown:add_value("Adjust", 6)
    type_dropdown:add_value("Music", 7)
    type_dropdown:add_value("Other", 8)
    
    note_dlg:add_label("Description:", 1, 3, 1, 1)
    local note_input = note_dlg:add_text_input("", 2, 3, 1, 1)
    
    note_dlg:add_button("Save Marker", function()
        local note_type = type_dropdown:get_value()
        local note_text = note_input:get_text()
        local type_names = {"Cut", "Add", "Audio", "Text", "Color", "Adjust", "Music", "Other"}
        local full_note = type_names[note_type] .. ": " .. note_text
        
        table.insert(markers, {time = time_seconds, note = full_note, type = type_names[note_type], description = note_text})
        vlc.msg.info("Marker #" .. #markers .. " saved: " .. format_timecode(time_seconds, 60) .. " - " .. full_note)
        
        note_dlg:delete()
        create_dialog()
    end, 1, 4, 1, 1)
    
    note_dlg:add_button("Cancel", function() 
        vlc.msg.info("Marker cancelled")
        note_dlg:delete()
        create_dialog()
    end, 2, 4, 1, 1)
end

function clear_markers()
    if #markers == 0 then
        return
    end
    
    if dlg then
        dlg:delete()
        dlg = nil
    end
    
    local confirm_dlg = vlc.dialog("Clear All Markers")
    confirm_dlg:add_label("Are you sure you want to clear all " .. #markers .. " markers?", 1, 1, 2, 1)
    confirm_dlg:add_button("Yes, Clear All", function()
        markers = {}
        vlc.msg.info("All markers cleared")
        confirm_dlg:delete()
        create_dialog()
    end, 1, 2, 1, 1)
    confirm_dlg:add_button("Cancel", function()
        confirm_dlg:delete()
        create_dialog()
    end, 2, 2, 1, 1)
end

function format_timecode(seconds, fps)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    local frames = math.floor((seconds - math.floor(seconds)) * fps)
    return string.format("%02d:%02d:%02d:%02d", hours, minutes, secs, frames)
end

function export_csv()
    vlc.msg.info("=== Export CSV clicked ===")
    
    if #markers == 0 then
        vlc.msg.warn("No markers to export!")
        return
    end
    
    if dlg then
        dlg:delete()
        dlg = nil
    end
    
    local export_dlg = vlc.dialog("Export CSV for Final Cut Pro")
    export_dlg:add_label("Enter filename (without extension):", 1, 1, 2, 1)
    local filename_input = export_dlg:add_text_input("markers_export", 1, 2, 2, 1)
    
    export_dlg:add_button("Export to Desktop", function()
        local filename = filename_input:get_text()
        if filename == "" then
            filename = "markers_export"
        end
        
        local desktop_path = os.getenv("HOME") .. "/Desktop/" .. filename .. ".csv"
        
        vlc.msg.info("Exporting CSV to: " .. desktop_path)
        
        -- Generate CSV content with proper escaping
        local csv = "Timecode,In TC,Out TC,Note Type,Description,Priority,Status,Reference\n"
        
        for i, marker in ipairs(markers) do
            local tc = format_timecode(marker.time, 60)
            local note_type = marker.type or "Other"
            local description = marker.description or marker.note or ""
            -- Escape quotes in description
            description = string.gsub(description, '"', '""')
            
            csv = csv .. tc .. ',,,""' .. note_type .. '","' .. description .. '",Medium,Pending,\n'
        end
        
        -- Write to file
        local file = io.open(desktop_path, "w")
        if file then
            file:write(csv)
            file:close()
            vlc.msg.info("CSV export successful: " .. desktop_path)
            
            export_dlg:delete()
            
            local success_dlg = vlc.dialog("CSV Export Successful!")
            success_dlg:add_label("CSV file exported to Desktop:", 1, 1, 1, 1)
            success_dlg:add_label(filename .. ".csv", 1, 2, 1, 1)
            success_dlg:add_label("Total markers: " .. #markers, 1, 3, 1, 1)
            success_dlg:add_label("", 1, 4, 1, 1)
            success_dlg:add_label("You can now use Marker Toolbox or", 1, 5, 1, 1)
            success_dlg:add_label("EditingTools.io to convert to FCPXML", 1, 6, 1, 1)
            success_dlg:add_button("OK", function()
                success_dlg:delete()
                create_dialog()
            end, 1, 7, 1, 1)
        else
            vlc.msg.err("Failed to write CSV file: " .. desktop_path)
            export_dlg:delete()
            create_dialog()
        end
    end, 1, 3, 1, 1)
    
    export_dlg:add_button("Cancel", function()
        export_dlg:delete()
        create_dialog()
    end, 2, 3, 1, 1)
end
