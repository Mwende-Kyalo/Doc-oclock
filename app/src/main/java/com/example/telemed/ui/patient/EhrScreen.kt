package com.example.telemed.ui.patient

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.telemed.data.local.EPrescription
import com.example.telemed.data.local.MedicalHistory
import com.example.telemed.ui.theme.TelemedTheme
import com.example.telemed.viewmodel.EhrUiState
import com.example.telemed.viewmodel.EhrViewModel

@Composable
fun EhrScreen(ehrViewModel: EhrViewModel = viewModel()) {
    val uiState by ehrViewModel.ehrUiState.collectAsState()
    EhrContent(uiState = uiState)
}

@Composable
fun EhrContent(uiState: EhrUiState) {
    var selectedTab by remember { mutableStateOf(0) }

    Column(modifier = Modifier.fillMaxSize()) {
        TabRow(selectedTabIndex = selectedTab) {
            Tab(
                selected = selectedTab == 0,
                onClick = { selectedTab = 0 },
                text = { Text("Medical History") }
            )
            Tab(
                selected = selectedTab == 1,
                onClick = { selectedTab = 1 },
                text = { Text("E-Prescriptions") }
            )
        }

        when (selectedTab) {
            0 -> MedicalHistoryList(uiState.medicalHistory)
            1 -> EPrescriptionList(uiState.ePrescriptions)
        }
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

@Preview(showBackground = true)
@Composable
fun EhrScreenPreview() {
    TelemedTheme {
        val fakeHistory = listOf(
            MedicalHistory(id = 1, patientId = 1, condition = "Headache", date = "22/10/2024", doctorName = "Dr. Feelgood"),
            MedicalHistory(id = 2, patientId = 1, condition = "Sore Throat", date = "23/10/2024", doctorName = "Dr. Smith")
        )
        val fakePrescriptions = listOf(
            EPrescription(id = 1, patientId = 1, doctorName = "Dr. Feelgood", date = "22/10/2024", medication = "Paracetamol", dosage = "500mg", frequency = "2 times a day"),
            EPrescription(id = 2, patientId = 1, doctorName = "Dr. Smith", date = "23/10/2024", medication = "Ibuprofen", dosage = "200mg", frequency = "3 times a day")
        )
        EhrContent(uiState = EhrUiState(medicalHistory = fakeHistory, ePrescriptions = fakePrescriptions))
    }
}