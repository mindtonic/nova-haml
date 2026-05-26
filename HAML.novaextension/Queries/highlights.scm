; HAML highlight queries — built against tree-sitter-haml's node-types.json.
; Scopes use Nova's core component vocabulary (tag.*, keyword, identifier,
; value, string, comment) so built-in themes reliably style them.

; ── Tags:  %div %span  (confirmed working) ──
(tag_name) @identifier.constant

; ── Classes & IDs:  .foo  — map to attribute family themes always color ──
(class_name) @tag.attribute.name

; ── Embedded Ruby: handled by injections.scm (Nova's Ruby grammar) ──
; (ruby_code / ruby_interpolation intentionally NOT highlighted here, so the
;  injected Ruby grammar colors method names, strings, symbols individually.)

; ── Output / run sigils ──
(ruby_block_output) @processing
(ruby_block_output_nuke) @processing
(ruby_block_sanitized) @processing
(ruby_block_preserve) @processing
(ruby_block_run) @processing

; ── Attributes:  {foo: "bar"}  (key="val") ──
(attribute_name) @tag.attribute.name
(quoted_attribute_value) @string
; (verbatim_string intentionally not highlighted — keeps plain text content default-colored)

; ── Doctype:  !!! 5 ──
(doctype_name) @keyword
(doctype_version) @value

; ── Comments:  -#  and  / ──
(comment) @comment
(comment_condition) @comment

; ── Object reference:  [@user] ──
(object_reference) @identifier

; ── Ruby variable flavors ──
(ruby_instance_variable) @identifier
(ruby_class_variable) @identifier
(ruby_global_variable) @identifier
(ruby_local_variable) @identifier
(ruby_constant) @value

; ── Filters:  :javascript  :css  :ruby ──
(filter_name) @keyword

; ── Escaped text ──
(escaped_text) @string
