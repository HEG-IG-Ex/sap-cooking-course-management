FUNCTION Z_FM_GENERATE_PARTCP_ID_074.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LASTNAME) TYPE  ZDE_NAME_074
*"     VALUE(IV_FIRSTNAME) TYPE  ZDE_NAME_074
*"  EXPORTING
*"     VALUE(EV_PARTCP_ID) TYPE  ZDE_PARTCP_ID_074
*"----------------------------------------------------------------------

 DATA: lv_lastname_code TYPE char3,
       lv_firstname_code TYPE char2,
       lv_count TYPE i,
       lv_count_str TYPE char3.

  " Extract first 3 letters of the last name
  lv_lastname_code = CONDENSE( iv_lastname+0(3) ).
  " Extract first 2 letters of the first name
  lv_firstname_code = CONDENSE( iv_firstname+0(2) ).

  " Fetch the count of participants from the database
  SELECT COUNT(*) FROM ztt_partcp_074 INTO lv_count.
  lv_count = lv_count + 1.

   " Convert numeric count to a zero-padded string
   lv_count_str = lv_count.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_count_str
    IMPORTING
      output = lv_count_str.  " Zero-padded string

  " Generate the ID by concatenating and formatting the count
  CONCATENATE lv_lastname_code lv_firstname_code lv_count_str INTO ev_partcp_id.

ENDFUNCTION.