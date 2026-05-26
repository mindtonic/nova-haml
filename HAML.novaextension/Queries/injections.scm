; Inject Nova's built-in Ruby grammar into HAML's Ruby spans, so embedded
; Ruby gets full highlighting (method names, strings, symbols, etc.) —
; e.g. `= render "shared/foo"` colors `render` and the string separately.
;
; Nova's required names: @injection.content marks the region, and the
; metadata key injection.language names the grammar to parse it with.

((ruby_code) @injection.content
  (#set! injection.language "ruby"))

((ruby_interpolation) @injection.content
  (#set! injection.language "ruby"))

((ruby_attributes) @injection.content
  (#set! injection.language "ruby"))

; Filter bodies (:javascript, :css, :ruby …) parsed by the filter's own language.
(filter
  (filter_name) @injection.language
  (filter_body) @injection.content)
