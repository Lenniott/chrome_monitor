# This tool helps accurately fill out timesheets by logging time spent on each Chrome tab, providing a clear record of online activities for precise tracking.

# Create the Required Files

1. **Log File**: The script logs data to a CSV file, which will be created automatically if it doesn’t exist. Ensure that the path specified in the script for the log file exists. For example:  
   \`LOG\_FILE="$HOME/Documents/chrome\_monitor/chrome\_focus\_log.csv"\`  
2. **Monitoring File**: This file is used to enable or disable monitoring.  
3. Create a file named isMonitoring.txt in the same directory as the script:  
   \`touch \~/Documents/chrome\_monitor/isMonitoring.txt\`  
4. Set the initial content to "false" so monitoring doesn’t start automatically:  
   \`echo "false" \> \~/Documents/chrome\_monitor/isMonitoring.txt\`

# Update File Paths in the Script

* Open chrome\_timer.sh in a text editor and update the file paths for LOG\_FILE and MONITORING\_FILE to reflect your directory structure. For example:  
  `` `LOG_FILE="$HOME/Documents/chrome_monitor/chrome_focus_log.csv"` ``  
  \`MONITORING\_FILE="$HOME/Documents/chrome\_monitor/isMonitoring.txt"\`

# Configure Apple Shortcuts for Enabling and Disabling Monitoring

* Open the **Shortcuts** app on your Mac.  
* **Create a Shortcut to Start Monitoring**:  
  * Name it something like "Start Chrome Monitoring".  
  * Add actions to:  
  * Get the content of isMonitoring.txt.  
  * Check if it’s set to "true". If not:  
  * Set the content to "true".  
  * Paste the chrome\_timer.sh script using a **Run Shell Script** action. (as bash)  
  * Save the shortcut.  
* **Create a Shortcut to Stop Monitoring**:  
  * Name it something like "Stop Chrome Monitoring".  
  * Add actions to:  
  * Get the content of isMonitoring.txt.  
  * Check if it’s set to "true". If so:  
  * Set the content to "false".  
  * Save the shortcut.

Refer to your screenshots as a guide for creating these shortcuts if needed.
[run bash script](images/Screenshot3.png)
[stop bash script](images/Screenshot4.png)

# Set Up Apple Calendar Automation

* Open the **Calendar** app and create two events: one for starting monitoring and one for stopping it.  
* **Starting Monitoring**:  
  * Create an event that runs every weekday (or any other schedule you prefer).  
  * Set the start time, such as **8:30 AM**.  
  * Under **Alert**, select **Custom** \> **Open file**, and choose the shortcut "Start Chrome Monitoring".  
* **Stopping Monitoring**:  
  * Create another event at the end of the day (e.g., **6:30 PM**).  
  * Under **Alert**, set it to **Open file** and select "Stop Chrome Monitoring".  
* These events will automate starting and stopping the monitoring each day.
[start bash script](images/Screenshot2.png)
[stop bash script](images/Screenshot1.png)

# Run the Tool Manually for Testing

You can test the setup by running the start and stop shortcuts manually from the Shortcuts app or by using the Calendar events.

# Viewing the Log Output

The monitoring script logs each focus change and tab change in chrome\_focus\_log.csv. You can open this file in a text editor or a spreadsheet application like Excel or Google Sheets to review the data.

# Usage Example

* At 8:30 AM, the Calendar will trigger the "Start Chrome Monitoring" shortcut, which sets isMonitoring.txt to "true" and starts chrome\_timer.sh.  
* At 6:30 PM, the Calendar will trigger the "Stop Chrome Monitoring" shortcut, which sets isMonitoring.txt to "false", causing the script to stop on its next loop check.  
* With this setup, other users can monitor Chrome usage with automatic daily logging and stopping, controlled through Apple Calendar and Shortcuts. They can adapt file paths and timings as needed based on their preferences.

