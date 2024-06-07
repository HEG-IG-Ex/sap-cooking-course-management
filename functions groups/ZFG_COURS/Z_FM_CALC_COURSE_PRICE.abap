FUNCTION Z_FM_CALC_COURSE_PRICE_074.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_COURSE_LVL) TYPE  ZDE_COURSE_LEVEL_074
*"     VALUE(IV_COURSE_DATE) TYPE  ZDE_DATE_074
*"  EXPORTING
*"     REFERENCE(EV_COURSE_PRICE) TYPE  ZDE_COURSE_PRICE_074
*"  EXCEPTIONS
*"      EX_INVALID_COURSE_LEVEL
*"----------------------------------------------------------------------
DATA: lv_base_price TYPE ZDE_COURSE_PRICE_074,
      lv_month TYPE I.

* Determine the base price based on the course level
CASE IV_COURSE_LVL.
  WHEN 'BEG'.
    lv_base_price = 150.
  WHEN 'INT'.
    lv_base_price = 180.
  WHEN 'ADV'.
    lv_base_price = 210.
  WHEN OTHERS.
    RAISE EX_INVALID_COURSE_LEVEL.
ENDCASE.

* Extract the month from the course date
lv_month = IV_COURSE_DATE+4(2).

* Adjust the price based on the month
CASE lv_month.
  WHEN 7 OR 8. " July or August
    lv_base_price = lv_base_price + ( lv_base_price * 10 / 100 ).
  WHEN 12. " December
    lv_base_price = lv_base_price + ( lv_base_price * 15 / 100 ).
ENDCASE.

* Return the calculated price
EV_COURSE_PRICE = lv_base_price.

ENDFUNCTION.