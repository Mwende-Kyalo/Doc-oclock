package com.example.telemed.ui.doctor

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.telemed.data.EHR
import com.example.telemed.data.Patient
import com.example.telemed.ui.theme.TelemedTheme
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PatientHistoryScreen(
    patient: Patient,
    ehrList: List<EHR>,
    onNavigateBack: () -> Unit,
    onAddEhr: (String) -> Unit,
    onEhrClicked: (EHR) -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("${patient.fullName} - EHR") },
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
        },
        floatingActionButton = {
            FloatingActionButton(onClick = { onAddEhr(patient.id) }) {
                Icon(Icons.Default.Add, contentDescription = "Add EHR")
            }
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            if (ehrList.isEmpty()) {
                item {
                    Text("No electronic health records found for this patient.")
                }
            } else {
                items(ehrList) { ehr ->
                    EhrRecordCard(ehr, onEhrClicked)
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EhrRecordCard(ehr: EHR, onEhrClicked: (EHR) -> Unit) {
    val dateFormatter = SimpleDateFormat("MMMM d, yyyy", Locale.getDefault())
    val date = Date(ehr.date)

    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(4.dp),
        onClick = { onEhrClicked(ehr) }
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text("Date: ${dateFormatter.format(date)}", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))
            Text("Diagnosis: ${ehr.diagnosis}", maxLines = 1)
            Text("Prescription: ${ehr.prescription}", maxLines = 1)
        }
    }
}

@Preview(showBackground = true)
@Composable
fun PatientHistoryScreenPreview() {
    TelemedTheme {
        val samplePatient = Patient("patient1", "Jane Doe")
        val sampleEhr = listOf(
            EHR(1, "patient1", "doc1", System.currentTimeMillis(), "Common Cold", "Rest and fluids", "Patient reported mild fever."),
            EHR(2, "patient1", "doc1", System.currentTimeMillis() - 86400000, "Headache", "Painkillers", "Patient complained of a persistent headache.")
        )
        PatientHistoryScreen(patient = samplePatient, ehrList = sampleEhr, onNavigateBack = {}, onAddEhr = {}, onEhrClicked = {})
    }
}
