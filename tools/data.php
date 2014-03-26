<?php
# If we run the script from the command line ...
if(defined('STDIN')) {
    # ... read data from test.txt.
    $chunk = file_get_contents("test.txt");
}
# If we run within an HTML page ...
else {
    # ... read the data through post ...
    $chunk = $_POST["data"];
    # ... and write it to tst.txt.
    file_put_contents("test.txt", $chunk, FILE_APPEND);
}
# Split the data into lines.
$lines = explode("\n", $chunk);
# Process one line at a time.
foreach($lines as $line) {
    # Skip lines if they don't match the expected criteria.
    if(!preg_match('/^\d+ \d+\.\d+( \d+)+$/', $line)) continue;
    # Split each line into its different fields.
    $words = explode(" ", $line);
    # Calculate date and time from the epoch time.
    $time = explode(" ", date('y m d H i s', (int) $words[0]));
    # Strip anything else but the counts.
    $values = array_slice($words, 2, count($words) - 3);
    if(preg_match('/Haselhang+/', getcwd())) {
        if($values[0] % 2) { 
            if(file_exists("odd.cookie")) {
                $values[0]++;
                unlink("odd.cookie");
            }
            else file_put_contents("odd.cookie", "");
        }
        $values[0] = (int) ($values[0] / 2);
    }
    # Declare and initialize an array to store the maximum of a day's counts.
    $max = array();
    # Declare and initialize an array to sum up a day's counts.
    $oldDaySum = array();
    $veryOldDaySum = array();
    # Declare and initialize the old total and max values.
    $totalAndMax = "";
    # Declare and initialize the old days histogram.
    $dayHist = "";
    # Declare and initialize the old month histogram.
    $monthHist = "";
    # Calculate the name of the file that contains today's histogram.
    $dayHistFile = "min$time[0]$time[1]$time[2].js";
    # If the day's total and max file and today's histogram exists ...
    if(file_exists("days.js")) {
        # ... we are still on the same day and need read the old total and max.
        $totalAndMax = file_get_contents("days.js");
        # Then we chop the trailing newline and the quotation mark.
        $totalAndMax = rtrim($totalAndMax, "\"\n");
    }
    strtok($totalAndMax, "\"");
    $oldDay = strtok(".");
    if($oldDay === false) $oldDay = $time[2];
    $oldMonth = strtok(".");
    if($oldMonth === false) $oldMonth = $time[1];
    $oldYear = strtok("|");
    if($oldYear === false) $oldYear = $time[0];
    # We remove the prologue if present ...
    strtok($totalAndMax, "|");
    # ... and iterate over as many data sets as we got.
    for($i = 0; $i < count($values); $i++) {
        # We try to get next data set.
        $totalAndMax = strtok("|");
        # If we got one ...
        if($totalAndMax !== false) {
            # ... we can split it into its fields ...
            $totalAndMaxArray = explode(";", $totalAndMax);
            # ... and finally assign the sum ...
            $oldDaySum[] = $totalAndMaxArray[0];
            $veryOldDaySum[] = $totalAndMaxArray[0];
            # ... and the max to be either the new ...
            if($values[$i] * 12 > $totalAndMaxArray[1]) $max[] = $values[$i] * 12;
            # ... or the stored value.
            else $max[] = $totalAndMaxArray[1];
        }
        # Otherwise, we assume ...
        else {
            # ... the sum ...
            $oldDaySum[] = 0;
            $veryOldDaySum[] = 0;
            # ... and the max to be the current value.
            $max[] = $values[$i] * 12;
        }
    }
    if(!file_exists($dayHistFile)) {
        for($i = 0; $i < count($values); $i++) {
            $oldDaySum[$i] = 0;
            $max[$i] = $values[$i] * 12;
        }
    }
    # We are ready to prepare the new files content now, i.e. the prolouge of today's histogram ...
    $minutes = "m[mi++]=\"$time[2].$time[1].$time[0] $time[3]:$time[4]:$time[5]";
    # ... and the files for days.js and the month histogram.
    $totalAndMax = "da[dx++]=\"" . $time[2] . "." . $time[1] . "." . $time[0];
    # Next, we iterate over all data sets, ...
    for($i = 0; $i < count($values); $i++) {
        # ... calculating the new sum ...
        $newDaySum = $oldDaySum[$i] + $values[$i];
        # ... and appending the appropriate values to today's historgam ...
        $minutes = "$minutes|" . ($values[$i] * 12) . ";" . ($values[$i] * 12) . ";" . $newDaySum . ";500";
        # ... and the files for days.js and the month histogram.
        $totalAndMax = "$totalAndMax|" . $newDaySum . ";" . $max[$i];
    }
    # If it already exists, we need to read it.
    if(file_exists($dayHistFile)) $dayHist = file_get_contents($dayHistFile);
    # If it doesn't exist, this must be a new day.
    else {
        # Declare and initialize the previous day's month histogram entry.
        $newMonthHistEntry = "";
        # Read the stored month histogram if it exists
        if(file_exists("days_hist.js")) $monthHist = file_get_contents("days_hist.js");
        # If the previous day's month histogram entry exists, ...
        if(file_exists("days.js")) {
            # ... we save it.
            $newMonthHistEntry = file_get_contents("days.js");
        }
        # Then we append the saved day to the month histogram.
        file_put_contents("days_hist.js", "$newMonthHistEntry$monthHist");

        # Declare and initialize the old year histogram.
        $yearHist = "";
        # Read the stored year histogram if it exists.
        if(file_exists("months.js")) $yearHist = file_get_contents("months.js");
        # Prepare the prologue for the year histogram.
        $newYearHistEntry = "mo[mx++]=\"" . $oldDay . "." . $oldMonth . "." . $oldYear;
        # Split the stored year histogram's into its first line ...
        $yearHistFirst = strtok($yearHist, "\n");
        # ... and the rest.
        $ret = preg_match('/^mo\[mx\+\+\]="(\d{2})\.(\d{2})\.(\d{2})((?:\|\d+)+)"$/', $yearHistFirst, $yearHistFirstArray);
        if($ret == 1 && $yearHistFirstArray[2] == $oldMonth && $yearHistFirstArray[3] == $oldYear) {
            $yearHistRemaining = strtok("");
        }
        else {
            $yearHistRemaining = $yearHist;
            $yearHistFirst = "";
        }
        # We remove the prologue if present ...
        strtok($yearHistFirst, "|");
        # ... and iterate over as many data sets as we got.
        for($i = 0; $i < count($values); $i++) {
            $newMonthTotal = 0;
            # We try to get next data set.
            $oldMonthTotal = strtok("|");
            # If we got one ...
            if($oldMonthTotal !== false) {
                # ... and finally assign the sum ...
                $newMonthTotal = $oldMonthTotal + $veryOldDaySum[$i];
            }
            # Otherwise, we assume ...
            else {
                # ... the sum ...
                $newMonthTotal = $veryOldDaySum[$i];
            }
            $newYearHistEntry = $newYearHistEntry . "|$newMonthTotal";
        }
        file_put_contents("months.js", "$newYearHistEntry\"\n$yearHistRemaining");

        # Declare and initialize the old overall histogram.
        $overallHist = "";
        # Read the stored overall histogram if it exists.
        if(file_exists("years.js")) $overallHist = file_get_contents("years.js");
        # Prepare the prologue for the overall histogram.
        $newOverallHistEntry = "ye[yx++]=\"" . $oldDay . "." . $oldMonth . "." . $oldYear;
        # Split the stored overall histogram's into its first line ...
        $overallHistFirst = strtok($overallHist, "\n");
        # ... and the rest.
        $ret = preg_match('/^ye\[yx\+\+\]="(\d{2})\.(\d{2})\.(\d{2})((?:\|\d+)+)"$/', $overallHistFirst, $overallHistFirstArray);
        if($ret == 1 && $overallHistFirstArray[3] == $oldYear) {
            $overallHistRemaining = strtok("");
        }
        else {
            $overallHistRemaining = $overallHist;
            $overallHistFirst = "";
        }
        # We remove the prologue if present ...
        strtok($overallHistFirst, "|");
        # ... and iterate over as many data sets as we got.
        for($i = 0; $i < count($values); $i++) {
            $newYearTotal = 0;
            # We try to get next data set.
            $oldYearTotal = strtok("|");
            # If we got one ...
            if($oldYearTotal !== false) {
                # ... and finally assign the sum ...
                $newYearTotal = $oldYearTotal + $veryOldDaySum[$i];
            }
            # Otherwise, we assume ...
            else {
                # ... the sum ...
                $newYearTotal = $veryOldDaySum[$i];
            }
            $newOverallHistEntry = $newOverallHistEntry . "|$newYearTotal";
        }
        file_put_contents("years.js", "$newOverallHistEntry\"\n$overallHistRemaining");
    }
    # Finally, we can write the data back, replacing it with the newly assembled line.
    file_put_contents("days.js", "$totalAndMax\"\n");
    # Finally, we can write the the day history back, prepended by the newly assembled line.
    file_put_contents($dayHistFile, "$minutes\"\n$dayHist");
    # Same content must be stored in that file.
    file_put_contents("min_day.js", "$minutes\"\n$dayHist");
}
