package com.example.telemed.data

import androidx.room.Dao
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface PatientDao {
    @Query("SELECT * FROM patients WHERE id = :patientId")
    fun getPatientById(patientId: String): Flow<Patient>
}
