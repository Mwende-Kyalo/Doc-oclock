package com.example.telemed.ui.doctor

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import androidx.navigation.compose.rememberNavController
import com.example.telemed.data.local.Appointment
import com.example.telemed.data.local.AppointmentAndPatient
import com.example.telemed.data.local.User
import com.example.telemed.ui.theme.TelemedTheme
import com.example.telemed.viewmodel.PatientRecordsViewModel

@Composable
fun PatientRecordsScreen(
    modifier: Modifier = Modifier,
    navController: NavController,
    patientRecordsViewModel: PatientRecordsViewModel = viewModel()
) {
    val appointments by patientRecordsViewModel.appointments.collectAsState()
    PatientRecordsContent(
        modifier = modifier,
        navController = navController,
        appointments = appointments
    )
}

@Composable
fun PatientRecordsContent(
    modifier: Modifier = Modifier,
    navController: NavController,
    appointments: List<AppointmentAndPatient>
) {
    LazyColumn(
        modifier = modifier
            .fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(appointments) { appointmentAndPatient ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { navController.navigate("patient_details/${appointmentAndPatient.appointment.id}/${appointmentAndPatient.patient.id}") }
            ) {
                Text(
                    text = appointmentAndPatient.patient.fullName,
                    modifier = Modifier.padding(16.dp)
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun PatientRecordsScreenPreview() {
    TelemedTheme {
        val fakeAppointments = listOf(
            AppointmentAndPatient(
                appointment = Appointment(id = 1, patientId = 1, doctorId = 1, appointmentDate = "22/10/2024", appointmentTime = "10:30", consultationType = "video", status = "booked"),
                patient = User(id = 1, fullName = "Mickey Mouse", email = "", phoneNumber = "", role = "Patient", passwordHash = "")
            ),
            AppointmentAndPatient(
                appointment = Appointment(id = 2, patientId = 2, doctorId = 1, appointmentDate = "23/10/2024", appointmentTime = "11:00", consultationType = "voice", status = "completed"),
                patient = User(id = 2, fullName = "Minnie Mouse", email = "", phoneNumber = "", role = "Patient", passwordHash = "")
            )
        )
        PatientRecordsContent(
            navController = rememberNavController(),
            appointments = fakeAppointments
        )
    }
}