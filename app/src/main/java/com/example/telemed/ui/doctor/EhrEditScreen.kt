package com.example.telemed.ui.doctor

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.telemed.data.EHR
import com.example.telemed.ui.theme.TelemedTheme

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EhrEditScreen(
    ehr: EHR?,
    patientId: String,
    onNavigateBack: () -> Unit,
    onSaveEhr: (EHR) -> Unit
) {
    var diagnosis by remember { mutableStateOf(ehr?.diagnosis ?: "") }
    var prescription by remember { mutableStateOf(ehr?.prescription ?: "") }
    var notes by remember { mutableStateof(ehr?.notes ?: "") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(if (ehr == null) "Add EHR" else "Edit EHR") },
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
            OutlinedTextField(
                value = diagnosis,
                onValueChange = { diagnosis = it },
                label = { Text("Diagnosis") },
                modifier = Modifier.fillMaxWidth()
            )
            Spacer(modifier = Modifier.height(16.dp))
            OutlinedTextField(
                value = prescription,
                onValueChange = { prescription = it },
                label = { Text("Prescription") },
                modifier = Modifier.fillMaxWidth()
            )
            Spacer(modifier = Modifier.height(16.dp))
            OutlinedTextField(
                value = notes,
                onValueChange = { notes = it },
                label = { Text("Notes") },
                modifier = Modifier.fillMaxWidth().weight(1f)
            )
            Spacer(modifier = Modifier.height(32.dp))
            Button(
                onClick = {
                    val newEhr = EHR(
                        id = ehr?.id ?: 0, // Room will handle auto-generation if id is 0
                        patientId = patientId,
                        doctorId = "", // Replace with actual doctor ID
                        date = System.currentTimeMillis(),
                        diagnosis = diagnosis,
                        prescription = prescription,
                        notes = notes
                    )
                    onSaveEhr(newEhr)
                },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Save Record")
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun EhrEditScreenPreview() {
    TelemedTheme {
        EhrEditScreen(ehr = null, patientId = "patient1", onNavigateBack = {}, onSaveEhr = {})
    }
}
