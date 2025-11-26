package com.example.telemed.ui.patient

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import android.widget.Toast
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.telemed.data.local.User
import com.example.telemed.ui.theme.TelemedTheme
import com.example.telemed.viewmodel.BookAppointmentViewModel
import java.util.Calendar

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookAppointmentScreen(modifier: Modifier = Modifier, bookAppointmentViewModel: BookAppointmentViewModel = viewModel()) {
    val doctors by bookAppointmentViewModel.doctors.collectAsState()

    BookAppointmentContent(
        modifier = modifier,
        doctors = doctors,
        selectedDoctor = bookAppointmentViewModel.selectedDoctor,
        onDoctorSelected = { bookAppointmentViewModel.selectedDoctor = it },
        selectedDate = bookAppointmentViewModel.selectedDate,
        onDateSelected = { bookAppointmentViewModel.selectedDate = it },
        selectedTime = bookAppointmentViewModel.selectedTime,
        onTimeSelected = { bookAppointmentViewModel.selectedTime = it },
        consultationType = bookAppointmentViewModel.consultationType,
        onConsultationTypeSelected = { bookAppointmentViewModel.consultationType = it },
        onBookAppointmentClicked = { bookAppointmentViewModel.onBookAppointmentClicked(1) }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookAppointmentContent(
    modifier: Modifier = Modifier,
    doctors: List<User>,
    selectedDoctor: User?,
    onDoctorSelected: (User) -> Unit,
    selectedDate: String,
    onDateSelected: (String) -> Unit,
    selectedTime: String,
    onTimeSelected: (String) -> Unit,
    consultationType: String,
    onConsultationTypeSelected: (String) -> Unit,
    onBookAppointmentClicked: () -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    val context = LocalContext.current

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        ExposedDropdownMenuBox(
            expanded = expanded,
            onExpandedChange = { expanded = !expanded }
        ) {
            OutlinedTextField(
                value = selectedDoctor?.fullName ?: "",
                onValueChange = { },
                readOnly = true,
                label = { Text("Select Doctor") },
                trailingIcon = {
                    ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
                },
                modifier = Modifier.menuAnchor().fillMaxWidth()
            )
            ExposedDropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false }
            ) {
                doctors.forEach { doctor ->
                    DropdownMenuItem(
                        text = { Text(doctor.fullName) },
                        onClick = {
                            onDoctorSelected(doctor)
                            expanded = false
                        }
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Date Picker
        Button(onClick = {
            val calendar = Calendar.getInstance()
            DatePickerDialog(
                context,
                { _, year, month, dayOfMonth ->
                    onDateSelected("$dayOfMonth/${month + 1}/$year")
                },
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH),
                calendar.get(Calendar.DAY_OF_MONTH)
            ).show()
        }) {
            Text(text = if (selectedDate.isNotBlank()) selectedDate else "Select Date")
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Time Picker
        Button(onClick = {
            val calendar = Calendar.getInstance()
            TimePickerDialog(
                context,
                { _, hourOfDay, minute ->
                    onTimeSelected(String.format("%02d:%02d", hourOfDay, minute))
                },
                calendar.get(Calendar.HOUR_OF_DAY),
                calendar.get(Calendar.MINUTE),
                false
            ).show()
        }) {
            Text(text = if (selectedTime.isNotBlank()) selectedTime else "Select Time")
        }

        Spacer(modifier = Modifier.height(16.dp))

        Row {
            RadioButton(
                selected = consultationType == "video",
                onClick = { onConsultationTypeSelected("video") }
            )
            Text(text = "Video", modifier = Modifier.align(Alignment.CenterVertically))
            Spacer(modifier = Modifier.width(16.dp))
            RadioButton(
                selected = consultationType == "voice",
                onClick = { onConsultationTypeSelected("voice") }
            )
            Text(text = "Voice", modifier = Modifier.align(Alignment.CenterVertically))
        }

        Spacer(modifier = Modifier.height(32.dp))

        Button(
            onClick = {
                onBookAppointmentClicked()
                Toast.makeText(context, "Appointment Booked!", Toast.LENGTH_SHORT).show()
            },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(text = "Book Appointment")
        }
    }
}


@Preview(showBackground = true)
@Composable
fun BookAppointmentScreenPreview() {
    TelemedTheme {
        val doctors = listOf(
            User(id = 1, fullName = "Dr. Feelgood", email = "", phoneNumber = "", role = "Doctor", passwordHash = ""),
            User(id = 2, fullName = "Dr. Smith", email = "", phoneNumber = "", role = "Doctor", passwordHash = "")
        )
        BookAppointmentContent(
            doctors = doctors,
            selectedDoctor = doctors[0],
            onDoctorSelected = {},
            selectedDate = "22/10/2024",
            onDateSelected = {},
            selectedTime = "10:30",
            onTimeSelected = {},
            consultationType = "video",
            onConsultationTypeSelected = {},
            onBookAppointmentClicked = {}
        )
    }
}