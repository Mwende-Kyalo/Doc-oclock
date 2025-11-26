package com.example.telemed.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface MedicalHistoryDao {
    @Insert
    suspend fun insertMedicalHistory(medicalHistory: MedicalHistory)

    @Query("SELECT * FROM medical_history WHERE patientId = :patientId")
    fun getMedicalHistoryForPatient(patientId: Int): Flow<List<MedicalHistory>>
}