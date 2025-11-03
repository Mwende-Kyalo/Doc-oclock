package com.example.telemed.data.local

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface DoctorAvailabilityDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAvailability(availability: DoctorAvailability)

    @Update
    suspend fun updateAvailability(availability: DoctorAvailability)

    @Delete
    suspend fun deleteAvailability(availability: DoctorAvailability)

    @Query("SELECT * FROM doctor_availability WHERE doctorId = :doctorId")
    fun getAvailabilityForDoctor(doctorId: Int): Flow<List<DoctorAvailability>>
}