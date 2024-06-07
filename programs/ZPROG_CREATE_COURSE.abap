*&---------------------------------------------------------------------*
*& Report ZPROG_CREATE_COURSE_074
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPROG_CREATE_COURSE_074.

DATA: wa_course TYPE zst_cours_074,
      lt_courses TYPE zti_course_074.

PARAMETERS: pa_code TYPE zde_course_code_074 OBLIGATORY,
            pa_title TYPE zde_course_title_074 OBLIGATORY,
            pa_desc TYPE zde_course_description_074,
            pa_date TYPE zde_date_074 OBLIGATORY,
            pa_level TYPE zde_course_level_074 OBLIGATORY AS LISTBOX VISIBLE LENGTH 20,
            pa_maxp TYPE zde_course_max_partcp_074 OBLIGATORY.

DATA: lv_success TYPE char1,
      lv_message TYPE char255,
      lv_reset TYPE abap_bool VALUE abap_false.

AT SELECTION-SCREEN OUTPUT.
  IF lv_reset = abap_true.
    CLEAR: pa_code, pa_title, pa_desc, pa_date, pa_level, pa_maxp.
    lv_reset = abap_false.
  ENDIF.

START-OF-SELECTION.

  CLEAR: wa_course.

  wa_course-code        = pa_code.
  wa_course-title       = pa_title.
  wa_course-description = pa_desc.
  wa_course-course_date = pa_date.
  wa_course-course_lvl  = pa_level.
  wa_course-max_partcp  = pa_maxp.

  APPEND wa_course TO lt_courses.

  CALL FUNCTION 'Z_FM_CREATE_COURS_074'
    EXPORTING
      it_courses      = lt_courses
    IMPORTING
      ev_success      = lv_success
      ev_message      = lv_message.

  IF lv_success = 'X'.
    MESSAGE lv_message TYPE 'S'.
    lv_reset := abap_true.
  ELSE.
    MESSAGE lv_message TYPE 'E'.
  ENDIF.

  LEAVE TO SCREEN 0.  " Refresh the selection screen