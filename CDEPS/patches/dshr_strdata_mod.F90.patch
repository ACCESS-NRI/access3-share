diff --git a/streams/dshr_strdata_mod.F90 b/streams/dshr_strdata_mod.F90
index 4f04ab5..2c06ee6 100644
--- a/streams/dshr_strdata_mod.F90
+++ b/streams/dshr_strdata_mod.F90
@@ -13,7 +13,7 @@ module dshr_strdata_mod
   use ESMF             , only : ESMF_FILEFORMAT_ESMFMESH, ESMF_FieldCreate
   use ESMF             , only : ESMF_FieldBundleCreate, ESMF_MESHLOC_ELEMENT, ESMF_FieldBundleAdd
   use ESMF             , only : ESMF_POLEMETHOD_ALLAVG, ESMF_EXTRAPMETHOD_NEAREST_STOD
-  use ESMF             , only : ESMF_REGRIDMETHOD_BILINEAR, ESMF_REGRIDMETHOD_NEAREST_STOD
+  use ESMF             , only : ESMF_REGRIDMETHOD_BILINEAR, ESMF_REGRIDMETHOD_PATCH, ESMF_REGRIDMETHOD_NEAREST_STOD, 
   use ESMF             , only : ESMF_REGRIDMETHOD_CONSERVE, ESMF_NORMTYPE_FRACAREA, ESMF_NORMTYPE_DSTAREA
   use ESMF             , only : ESMF_ClockGet, operator(-), operator(==), ESMF_CALKIND_NOLEAP
   use ESMF             , only : ESMF_FieldReGridStore, ESMF_FieldRedistStore, ESMF_UNMAPPEDACTION_IGNORE
@@ -565,6 +565,16 @@ contains
                   srcMaskValues=(/sdat%stream(ns)%src_mask_val/), &
                   srcTermProcessing=srcTermProcessing_Value, ignoreDegenerate=.true., rc=rc)
              if (chkerr(rc,__LINE__,u_FILE_u)) return
+          else if (trim(sdat%stream(ns)%mapalgo) == "patch") then
+             call ESMF_FieldRegridStore(sdat%pstrm(ns)%field_stream, lfield_dst, &
+                  routehandle=sdat%pstrm(ns)%routehandle, &
+                  regridmethod=ESMF_REGRIDMETHOD_PATCH,  &
+                  polemethod=ESMF_POLEMETHOD_ALLAVG, &
+                  extrapMethod=ESMF_EXTRAPMETHOD_NEAREST_STOD, &
+                  dstMaskValues=(/sdat%stream(ns)%dst_mask_val/), &
+                  srcMaskValues=(/sdat%stream(ns)%src_mask_val/), &
+                  srcTermProcessing=srcTermProcessing_Value, ignoreDegenerate=.true., rc=rc)
+             if (chkerr(rc,__LINE__,u_FILE_u)) return
           else if (trim(sdat%stream(ns)%mapalgo) == 'redist') then
              call ESMF_FieldRedistStore(sdat%pstrm(ns)%field_stream, lfield_dst, &
                   routehandle=sdat%pstrm(ns)%routehandle, &
