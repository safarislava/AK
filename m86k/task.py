def base64_decoding(input):
    """Decode base64 input string.

    - Result string should be represented as a correct C string.
    - Buffer size for the decoded message -- `0x40`, starts from `0x00`.
    - End of input -- new line.

    Python example args:
        input (str): The input string containing base64 data to decode.

    Returns:
        tuple: A tuple containing the base64 decoded string and the remaining input.
    """
    line, rest = read_line(input, 0x40)
    if line is None:
        return [overflow_error_value], rest

    try:
        decoded_str = base64.b64decode(line).decode("utf-8")

        if len(decoded_str) + 1 > 0x40:  # +1 for null terminator
            return [overflow_error_value], rest

        return cstr(decoded_str, 0x40)[0], rest
    except Exception:
        # Invalid base64 input
        return [-1], rest


assert base64_decoding('SGVsbG8gd29ybGQh\n') == ('Hello world!', '')
assert base64_decoding('UHl0aG9u\n') == ('Python', '')