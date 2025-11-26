package com.example.telemed.ui.doctor

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.telemed.data.local.DoctorAvailability
import com.example.telemed.ui.theme.TelemedTheme
import com.example.telemed.viewmodel.CalendarViewModel
import java.util.*

@Composable
fun CalendarScreen(modifier: Modifier = Modifier, calendarViewModel: CalendarViewModel = viewModel()) {
    val availability by calendarViewModel.availability.collectAsState()

    CalendarContent(
        modifier = modifier,
        availability = availability,
        date = calendarViewModel.date,
        onDateChanged = { calendarViewModel.date = it },
        startTime = calendarViewModel.startTime,
        onStartTimeChanged = { calendarViewModel.startTime = it },
        endTime = calendarViewModel.endTime,
        onEndTimeChanged = { calendarViewModel.endTime = it },
        onAddAvailability = { calendarViewModel.addAvailability() },
        onDeleteAvailability = { calendarViewModel.deleteAvailability(it) }
    )
}


@Composable
fun CalendarContent(
    modifier: Modifier = Modifier,
    availability: List<DoctorAvailability>,
    date: String,
    onDateChanged: (String) -> Unit,
    startTime: String,
    onStartTimeChanged: (String) -> Unit,
    endTime: String,
    onEndTimeChanged: (String) -> Unit,
    onAddAvailability: () -> Unit,
    onDeleteAvailability: (DoctorAvailability) -> Unit
) {
    val context = LocalContext.current

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        // Input fields
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceAround) {
            Button(onClick = {
                val calendar = Calendar.getInstance()
                DatePickerDialog(
                    context,
                    { _, year, month, dayOfMonth ->
                        onDateChanged("$dayOfMonth/${month + 1}/$year")
                    },
                    calendar.get(Calendar.YEAR),
                    calendar.get(Calendar.MONTH),
                    calendar.get(Calendar.DAY_OF_MONTH)
                ).show()
            }) {
                Text(text = if (date.isNotBlank()) date else "Select Date")
            }

            Button(onClick = {
                val calendar = Calendar.getInstance()
                TimePickerDialog(
                    context,
                    { _, hourOfDay, minute ->
                        onStartTimeChanged(String.format("%02d:%02d", hourOfDay, minute))
                    },
                    calendar.get(Calendar.HOUR_OF_DAY),
                    calendar.get(Calendar.MINUTE),
                    false
                ).show()
            }) {
                Text(text = if (startTime.isNotBlank()) startTime else "Start Time")
            }

            Button(onClick = {
                val calendar = Calendar.getInstance()
                TimePickerDialog(
                    context,
                    { _, hourOfDay, minute ->
                        onEndTimeChanged(String.format("%02d:%02d", hourOfDay, minute))
                    },
                    calendar.get(Calendar.HOUR_OF_DAY),
                    calendar.get(Calendar.MINUTE),
                    false
                ).show()
            }) {
                Text(text = if (endTime.isNotBlank()) endTime else "End Time")
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Button(
            onClick = onAddAvailability,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(text = "Add Availability")
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Availability list
        LazyColumn(modifier = Modifier.fillMaxSize()) {
            items(availability) { availabilitySlot ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(text = "Date: ${availabilitySlot.date}")
                            Text(text = "From: ${availabilitySlot.startTime} to ${availabilitySlot.endTime}")
                        }
                        Button(onClick = { onDeleteAvailability(availabilitySlot) }) {
                            Text("Delete")
                        }
                    }
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun CalendarScreenPreview() {
    TelemedTheme {
        val availability = listOf(
            DoctorAvailability(id = 1, doctorId = 1, date = "22/10/2024", startTime = "10:00", endTime = "11:00"),
            DoctorAvailability(id = 2, doctorId = 1, date = "23/10/2024", startTime = "14:00", endTime = "15:00")
        )
        CalendarContent(
            availability = availability,
            date = "",
            onDateChanged = {},
            startTime = "",
            onStartTimeChanged = {},
            endTime = "",
            onEndTimeChanged = {},
            onAddAvailability = {},
            onDeleteAvailability = {}
        )
    }
}
