*&---------------------------------------------------------------------*
*& Report ZPROG_SEARCH_REGISTRATION_074
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPROG_SEARCH_REGISTRATION_074.

TABLES: ztt_regs_074, ztt_course_074, ztt_partcp_074.

DATA: lt_results TYPE TABLE OF ZST_ALV_REGS_OUTPUT_074.

CONSTANTS: c_msg_class            TYPE symsgid VALUE 'ZMSG_SELECT_REGS_074',
           c_msg_invalid_wildcard TYPE symsgno VALUE '000'.

SELECTION-SCREEN BEGIN OF BLOCK blk_registration WITH FRAME TITLE text-001.
PARAMETERS: pa_regid TYPE zde_reg_id_074.
SELECT-OPTIONS: so_rdate FOR ztt_regs_074-reg_date,
                so_paid FOR ztt_regs_074-payment_status.
SELECTION-SCREEN END OF BLOCK blk_registration.

SELECTION-SCREEN BEGIN OF BLOCK blk_course WITH FRAME TITLE text-002.
PARAMETERS: pa_code TYPE zde_course_code_074.
PARAMETERS: pa_title TYPE ztt_course_074-title.
SELECT-OPTIONS: so_cdate FOR ztt_course_074-course_date.
PARAMETERS: pa_clvl TYPE zde_course_level_074 AS LISTBOX VISIBLE LENGTH 20.
SELECTION-SCREEN END OF BLOCK blk_course.

SELECTION-SCREEN BEGIN OF BLOCK blk_participant WITH FRAME TITLE text-003.
PARAMETERS: pa_last TYPE zde_name_074.
PARAMETERS: pa_first TYPE zde_name_074.
PARAMETERS: pa_email TYPE zde_email_074.
SELECTION-SCREEN END OF BLOCK blk_participant.

START-OF-SELECTION.
  PERFORM validate_no_wildcards USING pa_regid 'Registration ID'.
  PERFORM validate_no_wildcards USING pa_code 'Course Code'.
  PERFORM validate_no_wildcards USING pa_last 'Lastname'.
  PERFORM validate_no_wildcards USING pa_first 'Firstname'.
  PERFORM validate_no_wildcards USING pa_email 'Email'.
  PERFORM validate_date_range TABLES so_rdate.
  PERFORM validate_date_range TABLES so_cdate.

  IF sy-subrc <> 0.
    MESSAGE 'Invalid date range.' TYPE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  " Replace '*' with '%' for wildcard search
  PERFORM replace_wildcards CHANGING pa_title.

  PERFORM search_registrations.

  IF lt_results IS INITIAL.
    MESSAGE 'No registrations found for the given criteria.' TYPE 'I'.
  ELSE.
    PERFORM display_alv_output.
  ENDIF.

FORM validate_no_wildcards USING pv_value TYPE any
                                 pv_field_name TYPE string.
  IF pv_value CP '*%' OR pv_value CA '*%'.
    MESSAGE ID c_msg_class TYPE 'E' NUMBER c_msg_invalid_wildcard WITH pv_field_name.
    sy-subrc = 1.
  ELSE.
    sy-subrc = 0.
  ENDIF.
ENDFORM.

FORM validate_date_range TABLES p_so_date STRUCTURE so_rdate.
  LOOP AT p_so_date INTO DATA(ls_date_range).
    IF ls_date_range-low IS NOT INITIAL AND ls_date_range-high IS NOT INITIAL.
      IF ls_date_range-low > ls_date_range-high.
        sy-subrc = 1.
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.
  sy-subrc = 0.
ENDFORM.

FORM replace_wildcards CHANGING pv_value TYPE c.
  REPLACE ALL OCCURRENCES OF '*' IN pv_value WITH '%'.
ENDFORM.

FORM search_registrations.
  DATA: lv_where_clause TYPE string,
        lt_conditions TYPE TABLE OF string,
        lv_condition TYPE string.

  " Build dynamic WHERE clause
  IF pa_regid IS NOT INITIAL.
    APPEND |r~reg_id = '{ pa_regid }'| TO lt_conditions.
  ENDIF.

  IF pa_code IS NOT INITIAL.
    APPEND |c~code = '{ pa_code }'| TO lt_conditions.
  ENDIF.

  IF pa_clvl IS NOT INITIAL.
    APPEND |c~course_lvl = '{ pa_clvl }'| TO lt_conditions.
  ENDIF.

  IF pa_last IS NOT INITIAL.
    APPEND |p~lastname = '{ pa_last }'| TO lt_conditions.
  ENDIF.

  IF pa_first IS NOT INITIAL.
    APPEND |p~firstname = '{ pa_first }'| TO lt_conditions.
  ENDIF.

  IF pa_email IS NOT INITIAL.
    APPEND |p~email = '{ pa_email }'| TO lt_conditions.
  ENDIF.

  LOOP AT so_cdate INTO DATA(ls_rdate).
    IF ls_rdate-low IS NOT INITIAL AND ls_rdate-high IS INITIAL.
      APPEND |r~reg_date = '{ ls_rdate-low }'| TO lt_conditions.
    ELSE.
      APPEND |r~reg_date BETWEEN '{ ls_rdate-low }' AND '{ ls_rdate-high }'| TO lt_conditions.
    ENDIF.
  ENDLOOP.

  LOOP AT so_paid INTO DATA(ls_paid).
    APPEND |r~payment_status = '{ ls_paid-low }'| TO lt_conditions.
  ENDLOOP.

  IF pa_title IS NOT INITIAL.
    APPEND |c~title LIKE '{ pa_title }'| TO lt_conditions.
  ENDIF.

  LOOP AT so_cdate INTO DATA(ls_cdate).
    IF ls_cdate-low IS NOT INITIAL AND ls_cdate-high IS INITIAL.
      APPEND |c~course_date = '{ ls_cdate-low }'| TO lt_conditions.
    ELSE.
      APPEND |c~course_date BETWEEN '{ ls_cdate-low }' AND '{ ls_cdate-high }'| TO lt_conditions.
    ENDIF.
  ENDLOOP.

  " Combine all conditions into a single WHERE clause
  LOOP AT lt_conditions INTO lv_condition.
    CONCATENATE lv_where_clause ' AND ' lv_condition INTO lv_where_clause RESPECTING BLANKS.
  ENDLOOP.

  " Remove leading ' AND ' if present
  IF lv_where_clause CP ' AND *'.
    SHIFT lv_where_clause BY 4 PLACES.
  ENDIF.

  " Execute dynamic SQL
  SELECT r~reg_id, c~title, r~reg_date, p~lastname, p~firstname, r~payment_status
    FROM ztt_regs_074 AS r
    INNER JOIN ztt_course_074 AS c ON r~course_code = c~code
    INNER JOIN ztt_partcp_074 AS p ON r~partcp_id = p~partcp_id
    INTO CORRESPONDING FIELDS OF TABLE @lt_results
    WHERE (lv_where_clause).

  " Add a field for the line number
  LOOP AT lt_results INTO DATA(ls_result).
    ls_result-line_num = sy-tabix.
    MODIFY lt_results FROM ls_result.
  ENDLOOP.

ENDFORM.

FORM display_alv_output.
  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fieldcat TYPE slis_fieldcat_alv.

  " Add a field for the line number
  LOOP AT lt_results INTO DATA(ls_result).
    ls_result-line_num = sy-tabix.
    MODIFY lt_results FROM ls_result.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZST_ALV_REGS_OUTPUT_074' " Use the existing structure
    CHANGING
      ct_fieldcat      = lt_fieldcat
    EXCEPTIONS
      OTHERS           = 1.
  IF sy-subrc <> 0.
    MESSAGE 'Error in field catalog merge' TYPE 'E'.
    RETURN.
  ENDIF.

  " Ensure the row number field is in the correct position
  LOOP AT lt_fieldcat INTO ls_fieldcat.
    CASE ls_fieldcat-fieldname.
      WHEN 'LINE_NUM'.
        ls_fieldcat-seltext_m = '#'.
        ls_fieldcat-col_pos = 1.
      WHEN 'REG_ID'.
        ls_fieldcat-seltext_m = '#'.
        ls_fieldcat-col_pos = 2.
      WHEN 'TITLE'.
        ls_fieldcat-col_pos = 3.
      WHEN 'REG_DATE'.
        ls_fieldcat-seltext_m = 'Registration Date'.
        ls_fieldcat-col_pos = 4.
      WHEN 'LASTNAME'.
        ls_fieldcat-seltext_m = 'Lasntame'.
        ls_fieldcat-col_pos = 5.
      WHEN 'FIRSTNAME'.
        ls_fieldcat-seltext_m = 'Firstname'.
        ls_fieldcat-col_pos = 6.
      WHEN 'PAYMENT_STATUS'.
        ls_fieldcat-col_pos = 7.
    ENDCASE.
    MODIFY lt_fieldcat FROM ls_fieldcat.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat      = lt_fieldcat
      i_structure_name = 'ZST_ALV_REGS_OUTPUT_074' " Use the existing structure
    TABLES
      t_outtab         = lt_results
    EXCEPTIONS
      OTHERS           = 1.
  IF sy-subrc <> 0.
    MESSAGE 'Error in ALV grid display' TYPE 'E'.
  ENDIF.

ENDFORM.