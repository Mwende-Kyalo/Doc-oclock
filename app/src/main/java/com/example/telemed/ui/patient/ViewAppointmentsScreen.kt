package com.example.telemed.ui.patient

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import androidx.navigation.compose.rememberNavController
import com.example.telemed.data.local.Appointment
import com.example.telemed.data.local.AppointmentAndDoctor
import com.example.telemed.data.local.User
import com.example.telemed.ui.theme.TelemedTheme
import com.example.telemed.viewmodel.ViewAppointmentsViewModel

@Composable
fun ViewAppointmentsScreen(
    modifier: Modifier = Modifier,
    navController: NavController,
    viewAppointmentsViewModel: ViewAppointmentsViewModel = viewModel()
) {
    val appointments by viewAppointmentsViewModel.appointments.collectAsState()

    ViewAppointmentsContent(
        modifier = modifier,
        navController = navController,
        appointments = appointments,
        onDeleteAppointment = { viewAppointmentsViewModel.deleteAppointment(it) },
        onUpdateAppointment = { viewAppointmentsViewModel.updateAppointment(it) }
    )
}

@Composable
fun ViewAppointmentsContent(
    modifier: Modifier = Modifier,
    navController: NavController,
    appointments: List<AppointmentAndDoctor>,
    onDeleteAppointment: (Appointment) -> Unit,
    onUpdateAppointment: (Appointment) -> Unit
) {
    var showDeleteDialog by remember { mutableStateOf<Appointment?>(null) }
    var showEditDialog by remember { mutableStateOf<Appointment?>(null) }

    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(appointments) { appointmentAndDoctor ->
            val appointment = appointmentAndDoctor.appointment
            Card(
                modifier = Modifier.fillMaxWidth(),
                elevation = CardDefaults.cardElevation(4.dp)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(text = "Doctor: ${appointmentAndDoctor.doctor.fullName}")
                    Text(text = "Date: ${appointment.appointmentDate}")
                    Text(text = "Time: ${appointment.appointmentTime}")
                    Text(text = "Type: ${appointment.consultationType}")
                    Text(text = "Status: ${appointment.status}")
                    Spacer(modifier = Modifier.height(16.dp))
                    Row {
                        Button(onClick = { showEditDialog = appointment }) {
                            Text(text = "Edit")
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                        Button(onClick = { showDeleteDialog = appointment }, colors = ButtonDefaults.buttonColors(containerColor = Color.Red)) {
                            Text(text = "Delete")
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                        Button(onClick = { navController.navigate(PatientScreen.BookAppointment.route) }) {
                            Text(text = "Reschedule")
                        }
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                    Row {
                        Button(onClick = { navController.navigate("chat/${appointment.id}/${appointment.doctorId}") }) {
                            Text(text = "Chat")
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                        Button(onClick = { navController.navigate(PatientScreen.VideoCall.route) }) {
                            Text(text = "Video Call")
                        }
                    }
                }
            }
        }
    }

    showDeleteDialog?.let { appointment ->
        AlertDialog(
            onDismissRequest = { showDeleteDialog = null },
            title = { Text("Delete Appointment") },
            text = { Text("Are you sure you want to delete this appointment?") },
            confirmButton = {
                Button(
                    onClick = {
                        onDeleteAppointment(appointment)
                        showDeleteDialog = null
                    }
                ) {
                    Text("Delete")
                }
            },
            dismissButton = {
                Button(onClick = { showDeleteDialog = null }) {
                    Text("Cancel")
                }
            }
        )
    }

    showEditDialog?.let { appointment ->
        var consultationType by remember { mutableStateOf(appointment.consultationType) }
        AlertDialog(
            onDismissRequest = { showEditDialog = null },
            title = { Text("Edit Appointment") },
            text = {
                Column {
                    Row {
                        RadioButton(selected = consultationType == "video", onClick = { consultationType = "video" })
                        Text("Video")
                    }
                    Row {
                        RadioButton(selected = consultationType == "voice", onClick = { consultationType = "voice" })
                        Text("Voice")
                    }
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        onUpdateAppointment(appointment.copy(consultationType = consultationType))
                        showEditDialog = null
                    }
                ) {
                    Text("Save")
                }
            },
            dismissButton = {
                Button(onClick = { showEditDialog = null }) {
                    Text("Cancel")
                }
            }
        )
    }
}


@Preview(showBackground = true)
@Composable
fun ViewAppointmentsScreenPreview() {
    TelemedTheme {
        val fakeAppointments = listOf(
            AppointmentAndDoctor(
                appointment = Appointment(id = 1, patientId = 1, doctorId = 1, appointmentDate = "22/10/2024", appointmentTime = "10:30", consultationType = "video", status = "booked"),
                doctor = User(id = 1, fullName = "Dr. Feelgood", email = "", phoneNumber = "", role = "Doctor", passwordHash = "")
            ),
            AppointmentAndDoctor(
                appointment = Appointment(id = 2, patientId = 1, doctorId = 2, appointmentDate = "23/10/2024", appointmentTime = "11:00", consultationType = "voice", status = "completed"),
                doctor = User(id = 2, fullName = "Dr. Smith", email = "", phoneNumber = "", role = "Doctor", passwordHash = "")
            )
        )
        ViewAppointmentsContent(
            navController = rememberNavController(),
            appointments = fakeAppointments,
            onDeleteAppointment = {},
            onUpdateAppointment = {}
        )
    }
}