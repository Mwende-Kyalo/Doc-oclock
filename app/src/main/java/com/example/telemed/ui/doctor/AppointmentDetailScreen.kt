package com.example.telemed.ui.doctor

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.telemed.data.Appointment
import com.example.telemed.data.ConsultationMethod
import com.example.telemed.data.Patient
import com.example.telemed.ui.theme.TelemedTheme
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppointmentDetailScreen(
    appointment: Appointment,
    patient: Patient,
    onNavigateBack: () -> Unit,
    onStartCall: (ConsultationMethod) -> Unit,
    onViewHistory: (String) -> Unit,
    onEditAppointment: (String) -> Unit
) {
    val timeFormatter = SimpleDateFormat("EEEE, MMMM d, yyyy 'at' hh:mm a", Locale.getDefault())
    val date = Date(appointment.appointmentTime)

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Appointment Details") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = Color.White,
                    navigationIconContentColor = Color.White
                )
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp)
        ) {
            Text("Patient: ${patient.fullName}", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))
            Text("Date & Time: ${timeFormatter.format(date)}")
            Spacer(modifier = Modifier.height(8.dp))
            Text("Consultation Method: ${appointment.consultationMethod.name}")
            Spacer(modifier = Modifier.height(24.dp))

            Button(
                onClick = { onStartCall(appointment.consultationMethod) },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(when (appointment.consultationMethod) {
                    ConsultationMethod.VIDEO -> "Start Video Call"
                    ConsultationMethod.AUDIO -> "Start Audio Call"
                })
            }
            Spacer(modifier = Modifier.height(16.dp))
            OutlinedButton(
                onClick = { onViewHistory(patient.id) },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("View Patient History (EHR)")
            }
            Spacer(modifier = Modifier.height(16.dp))
            TextButton(
                onClick = { onEditAppointment(appointment.id) },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Edit Appointment Details")
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun AppointmentDetailScreenPreview() {
    TelemedTheme {
        val sampleAppointment = Appointment("1", "patient1", "doc1", System.currentTimeMillis(), ConsultationMethod.VIDEO, "Upcoming")
        val samplePatient = Patient("patient1", "Jane Doe")
        AppointmentDetailScreen(
            appointment = sampleAppointment,
            patient = samplePatient,
            onNavigateBack = {},
            onStartCall = {},
            onViewHistory = {},
            onEditAppointment = {}
        )
    }
}
