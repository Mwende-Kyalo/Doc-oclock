package com.example.telemed.ui.doctor

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalInspectionMode
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import androidx.navigation.compose.rememberNavController
import com.example.telemed.data.local.EPrescription
import com.example.telemed.data.local.MedicalHistory
import com.example.telemed.data.local.User
import com.example.telemed.ui.theme.TelemedTheme
import com.example.telemed.viewmodel.PatientDetailsUiState
import com.example.telemed.viewmodel.PatientDetailsViewModel

@Composable
fun PatientDetailsScreen(navController: NavController, patientDetailsViewModel: PatientDetailsViewModel = viewModel()) {
    // This check prevents the ViewModel from being created in preview mode, which causes a crash.
    if (LocalInspectionMode.current) {
        PatientDetailsContent(navController, null, PatientDetailsUiState(), { _, _, _ -> }, { _, _, _, _, _ -> }, 1)
        return
    }

    val patient by patientDetailsViewModel.patient.collectAsState()
    val uiState by patientDetailsViewModel.patientDetailsUiState.collectAsState()

    PatientDetailsContent(
        navController = navController,
        patient = patient,
        uiState = uiState,
        onAddMedicalHistory = { condition, date, doctorName -> patientDetailsViewModel.addMedicalHistory(condition, date, doctorName) },
        onAddEPrescription = { medication, dosage, frequency, doctorName, date -> patientDetailsViewModel.addEPrescription(medication, dosage, frequency, doctorName, date) },
        appointmentId = patientDetailsViewModel.appointmentId
    )
}

@Composable
fun PatientDetailsContent(
    navController: NavController,
    patient: User?,
    uiState: PatientDetailsUiState,
    onAddMedicalHistory: (String, String, String) -> Unit,
    onAddEPrescription: (String, String, String, String, String) -> Unit,
    appointmentId: Int
) {
    var showAddMedicalHistoryDialog by remember { mutableStateOf(false) }
    var showAddEPrescriptionDialog by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        patient?.let {
            Text(text = "Name: ${it.fullName}", style = MaterialTheme.typography.headlineMedium)
            Text(text = "Email: ${it.email}", style = MaterialTheme.typography.bodyLarge)
            Text(text = "Phone: ${it.phoneNumber}", style = MaterialTheme.typography.bodyLarge)
        }

        Spacer(modifier = Modifier.height(16.dp))

        Row {
            Button(onClick = { showAddMedicalHistoryDialog = true }) {
                Text("Add Medical History")
            }
            Spacer(modifier = Modifier.width(16.dp))
            Button(onClick = { showAddEPrescriptionDialog = true }) {
                Text("Add E-Prescription")
            }
        }

        Spacer(modifier = Modifier.height(8.dp))
        Row {
            Button(onClick = { navController.navigate("chat/$appointmentId/${patient?.id ?: -1}") }) {
                Text("Chat")
            }
            Spacer(modifier = Modifier.width(8.dp))
            Button(onClick = { navController.navigate(DoctorScreen.VideoCall.route) }) {
                Text("Video Call")
            }
        }


        Spacer(modifier = Modifier.height(16.dp))

        var selectedTab by remember { mutableStateOf(0) }
        TabRow(selectedTabIndex = selectedTab) {
            Tab(selected = selectedTab == 0, onClick = { selectedTab = 0 }, text = { Text("Medical History") })
            Tab(selected = selectedTab == 1, onClick = { selectedTab = 1 }, text = { Text("E-Prescriptions") })
        }

        when (selectedTab) {
            0 -> MedicalHistoryList(uiState.medicalHistory)
            1 -> EPrescriptionList(uiState.ePrescriptions)
        }
    }

    if (showAddMedicalHistoryDialog) {
        AddMedicalHistoryDialog(
            onDismiss = { showAddMedicalHistoryDialog = false },
            onSave = {
                onAddMedicalHistory(it.condition, it.date, it.doctorName)
                showAddMedicalHistoryDialog = false
            }
        )
    }

    if (showAddEPrescriptionDialog) {
        AddEPrescriptionDialog(
            onDismiss = { showAddEPrescriptionDialog = false },
            onSave = {
                onAddEPrescription(it.medication, it.dosage, it.frequency, it.doctorName, it.date)
                showAddEPrescriptionDialog = false
            }
        )
    }
}

@Composable
fun MedicalHistoryList(history: List<MedicalHistory>) {
    LazyColumn(modifier = Modifier.padding(16.dp)) {
        items(history) { item ->
            Card(modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp)) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(text = "Condition: ${item.condition}")
                    Text(text = "Date: ${item.date}")
                    Text(text = "Doctor: ${item.doctorName}")
                }
            }
        }
    }
}

@Composable
fun EPrescriptionList(prescriptions: List<EPrescription>) {
    LazyColumn(modifier = Modifier.padding(16.dp)) {
        items(prescriptions) { item ->
            Card(modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp)) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(text = "Medication: ${item.medication}")
                    Text(text = "Dosage: ${item.dosage}")
                    Text(text = "Frequency: ${item.frequency}")
                    Text(text = "Doctor: ${item.doctorName}")
                    Text(text = "Date: ${item.date}")
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddMedicalHistoryDialog(onDismiss: () -> Unit, onSave: (MedicalHistory) -> Unit) {
    var condition by remember { mutableStateOf("") }
    var date by remember { mutableStateOf("") }
    var doctorName by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add Medical History") },
        text = {
            Column {
                OutlinedTextField(value = condition, onValueChange = { condition = it }, label = { Text("Condition") })
                OutlinedTextField(value = date, onValueChange = { date = it }, label = { Text("Date") })
                OutlinedTextField(value = doctorName, onValueChange = { doctorName = it }, label = { Text("Doctor Name") })
            }
        },
        confirmButton = {
            Button(onClick = { onSave(MedicalHistory(condition = condition, date = date, doctorName = doctorName, patientId = 0)) }) {
                Text("Save")
            }
        },
        dismissButton = { Button(onClick = onDismiss) { Text("Cancel") } }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddEPrescriptionDialog(onDismiss: () -> Unit, onSave: (EPrescription) -> Unit) {
    var medication by remember { mutableStateOf("") }
    var dosage by remember { mutableStateOf("") }
    var frequency by remember { mutableStateOf("") }
    var doctorName by remember { mutableStateOf("") }
    var date by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add E-Prescription") },
        text = {
            Column {
                OutlinedTextField(value = medication, onValueChange = { medication = it }, label = { Text("Medication") })
                OutlinedTextField(value = dosage, onValueChange = { dosage = it }, label = { Text("Dosage") })
                OutlinedTextField(value = frequency, onValueChange = { frequency = it }, label = { Text("Frequency") })
                OutlinedTextField(value = doctorName, onValueChange = { doctorName = it }, label = { Text("Doctor Name") })
                OutlinedTextField(value = date, onValueChange = { date = it }, label = { Text("Date") })
            }
        },
        confirmButton = {
            Button(onClick = { onSave(EPrescription(medication = medication, dosage = dosage, frequency = frequency, doctorName = doctorName, date = date, patientId = 0)) }) {
                Text("Save")
            }
        },
        dismissButton = { Button(onClick = onDismiss) { Text("Cancel") } }
    )
}

@Preview(showBackground = true)
@Composable
fun PatientDetailsScreenPreview() {
    TelemedTheme {
        val fakeHistory = listOf(
            MedicalHistory(id = 1, patientId = 1, condition = "Headache", date = "22/10/2024", doctorName = "Dr. Feelgood"),
            MedicalHistory(id = 2, patientId = 1, condition = "Sore Throat", date = "23/10/2024", doctorName = "Dr. Smith")
        )
        val fakePrescriptions = listOf(
            EPrescription(id = 1, patientId = 1, doctorName = "Dr. Feelgood", date = "22/10/2024", medication = "Paracetamol", dosage = "500mg", frequency = "2 times a day"),
            EPrescription(id = 2, patientId = 1, doctorName = "Dr. Smith", date = "23/10/2024", medication = "Ibuprofen", dosage = "200mg", frequency = "3 times a day")
        )
        PatientDetailsContent(
            navController = rememberNavController(),
            patient = User(id = 1, fullName = "Mickey Mouse", email = "mickey@mouse.com", phoneNumber = "1234567890", role = "Patient", passwordHash = ""),
            uiState = PatientDetailsUiState(medicalHistory = fakeHistory, ePrescriptions = fakePrescriptions),
            onAddMedicalHistory = { _, _, _ -> },
            onAddEPrescription = { _, _, _, _, _ -> },
            appointmentId = 1
        )
    }
}