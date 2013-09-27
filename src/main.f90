module PoisFFT
#ifdef MPI
  use PFFT
#endif

  use PoisFFT_Precisions
  
  use PoisFFT_Parameters

  use PoisFFT_SP, PoisFFT_Solver1D_SP => PoisFFT_Solver1D, &
                  PoisFFT_Solver2D_SP => PoisFFT_Solver2D, &
                  PoisFFT_Solver3D_SP => PoisFFT_Solver3D

  use PoisFFT_DP, PoisFFT_Solver1D_DP => PoisFFT_Solver1D, &
                  PoisFFT_Solver2D_DP => PoisFFT_Solver2D, &
                  PoisFFT_Solver3D_DP => PoisFFT_Solver3D
contains
#ifdef MPI    
    subroutine PoisFFT_InitMPIGrid(MPI_comm, np, PoisFFT_comm, ierror)
      integer(c_int32_t), intent(in) :: mpi_comm
      integer(c_int), intent(in) :: np(:)
      integer(c_int32_t), intent(out) :: PoisFFT_comm, ierror
      !This will fail to compile if integer /= 4 bytes as Fortran MPI2 and PFFT assumes.
      ierror = pfft_create_procmesh_2d(MPI_comm, &
                                       np(1), &
                                       np(2), &
                                       PoisFFT_comm)
                                       
      if (ierror > 0) return
      
      
    end subroutine
    
    subroutine PoisFFT_LocalGridSize(rnk,Nos,PoisFFT_comm,local_ni,local_i_start,local_no,local_o_start)
      integer(c_int), value :: rnk
      integer(c_intptr_t), intent(in) :: Nos(:)
      integer(c_int32_t), intent(in) :: PoisFFT_comm
      integer(c_intptr_t), intent(out) :: local_ni(:)
      integer(c_intptr_t), intent(out) :: local_i_start(:)
      integer(c_intptr_t), intent(out) :: local_no(:)
      integer(c_intptr_t), intent(out) :: local_o_start(:)
      integer(c_intptr_t) :: alloc_local
      integer(c_intptr_t) :: Nback(1:size(Nos))
      
      Nback = Nos(rnk:1:-1) !not necessary, but to avoid warnings about temporary array passed
!       alloc_local = pfft_local_size_dft(rnk,Nback,PoisFFT_comm, &
!                                         PFFT_TRANSPOSED_NONE, &
!                                         local_ni,local_i_start,local_no,local_o_start)
      alloc_local = pfft_local_size_dft_3d(Nback, PoisFFT_comm, PFFT_TRANSPOSED_NONE, &
                                           local_ni, local_i_start, local_no, local_o_start)
      local_ni = local_ni(rnk:1:-1)
      local_i_start = local_i_start(rnk:1:-1)
      local_no = local_no(rnk:1:-1)
      local_o_start = local_o_start(rnk:1:-1)

    end subroutine
#endif
end module PoisFFT