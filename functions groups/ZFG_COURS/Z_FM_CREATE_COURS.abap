FUNCTION Z_FM_CREATE_COURS_074.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_COURSES) TYPE  ZTI_COURSE_074
*"  EXPORTING
*"     VALUE(EV_SUCCESS) TYPE  CHAR1
*"     VALUE(EV_MESSAGE) TYPE  CHAR255
*"----------------------------------------------------------------------

DATA: ls_course TYPE ZST_COURS_074,
      lv_dummy TYPE ZST_COURS_074,
      lv_match_found TYPE abap_bool,
      lv_course_code  TYPE string.


CONSTANTS: c_msg_class            TYPE symsgid VALUE 'ZMSG_COURS_074',
           c_msg_success          TYPE symsgno VALUE '000',
           c_msg_insert_error     TYPE symsgno VALUE '001',
           c_msg_dupl_code_error  TYPE symsgno VALUE '002',
           c_msg_past_date_error  TYPE symsgno VALUE '003',
           c_msg_price_calc_error TYPE symsgno VALUE '004',
           c_msg_crs_lvl_error    TYPE symsgno VALUE '005',
           c_max_length TYPE i VALUE 10,
           c_regex_course_code    TYPE string VALUE '^[A-Za-z0-9]{1,10}$'.

* Validate input courses
LOOP AT it_courses INTO ls_course.

  " Validate mandatory fields
  IF ls_course-code IS INITIAL OR ls_course-title IS INITIAL OR ls_course-course_date IS INITIAL OR
     ls_course-course_lvl IS INITIAL OR ls_course-max_partcp IS INITIAL.
    ev_success = ' '.
    ev_message = 'Missing mandatory input data'.
    RETURN.
  ENDIF.

  lv_course_code = ls_course-code.

  " Validate course code format and length
  FIND REGEX c_regex_course_code IN lv_course_code MATCH COUNT lv_match_found.
  IF lv_match_found = 0.
    ev_success = ' '.
    ev_message = 'Invalid course code. Only letters and numbers allowed, max 10 characters.'.
    RETURN.
  ENDIF.

  " Check if course code already exists
  SELECT SINGLE * FROM ztt_course_074 INTO @lv_dummy WHERE code = @ls_course-code.
  IF sy-subrc = 0.
    ev_success = ' '.
    MESSAGE ID c_msg_class TYPE 'E' NUMBER c_msg_dupl_code_error INTO ev_message.
    RETURN.
  ENDIF.

  " Validate course date
  IF ls_course-course_date < sy-datum.
    ev_success = ' '.
    MESSAGE ID c_msg_class TYPE 'E' NUMBER c_msg_past_date_error INTO ev_message.
    RETURN.
  ENDIF.

  " Calculate course price
  CALL FUNCTION 'Z_FM_CALC_COURSE_PRICE_074'
    EXPORTING
      iv_course_lvl   = ls_course-course_lvl
      iv_course_date  = ls_course-course_date
    IMPORTING
      ev_course_price = ls_course-price
    EXCEPTIONS
      ex_invalid_course_level = 1
      others                  = 2.

  IF sy-subrc = 1.
    ev_success = ' '.
    MESSAGE ID c_msg_class TYPE 'E' NUMBER c_msg_crs_lvl_error WITH ls_course-course_lvl INTO ev_message.
    RETURN.
  ELSEIF sy-subrc = 2.
    ev_success = ' '.
    MESSAGE ID c_msg_class TYPE 'E' NUMBER c_msg_price_calc_error INTO ev_message.
    RETURN.
  ENDIF.

  " Insert course into database
  TRY.
      INSERT INTO ZTT_COURSE_074 VALUES ls_course.
      IF sy-subrc = 0.
        ev_success = 'X'.
        MESSAGE ID c_msg_class TYPE 'S' NUMBER c_msg_success INTO ev_message.
      ELSE.
        ev_success = ' '.
        MESSAGE ID c_msg_class TYPE 'E' NUMBER c_msg_insert_error WITH sy-subrc INTO ev_message.
      ENDIF.
    CATCH CX_SY_OPEN_SQL_DB INTO DATA(lx_sql_error).
      ev_success = ' '.
      ev_message = lx_sql_error->get_text( ).
  ENDTRY.

ENDLOOP.

ENDFUNCTION.