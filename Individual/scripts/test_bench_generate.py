
"""
%Generate IEEE-754 single-precision test vectors for an RTL FPU.

The generated vectors contain:
    operation, operand A, operand B, expected result

Operations:
    ADD
    SUB
    MUL
    DIV

The reference calculation is performed using Python float, then converted
to IEEE-754 binary32. The RTL should compare the resulting 32-bit bit
patterns.

Usage:
    python3 generate_fp_tests.py
    python3 generate_fp_tests.py --count 1000 --output fp_tests.txt
"""

import argparse
import math
import random
import struct
from pathlib import Path


OPS = {
    "ADD": 0,
    "SUB": 1,
    "MUL": 2,
    "DIV": 3,
}


def float_to_bits32(x: float) -> int:
    """Convert a Python float to IEEE-754 binary32 bit pattern."""
    return struct.unpack(">I", struct.pack(">f", x))[0]


def bits32_to_float(bits: int) -> float:
    """Convert IEEE-754 binary32 bit pattern to Python float."""
    return struct.unpack(">f", struct.pack(">I", bits & 0xFFFFFFFF))[0]


def binary32(x: float) -> float:
    """Round a Python float to binary32 and return it as Python float."""
    return bits32_to_float(float_to_bits32(x))


def reference(op: str, a: float, b: float) -> float:
    """Calculate the reference result using Python arithmetic."""
    if op == "ADD":
        return a + b
    if op == "SUB":
        return a - b
    if op == "MUL":
        return a * b
    if op == "DIV":
        # Python raises ZeroDivisionError for float / zero.
        # IEEE-754 instead produces infinity or NaN.
        if b == 0.0:
            if a == 0.0:
                return float("nan")
            return math.copysign(float("inf"), a * b if b != 0.0 else a)
        return a / b
    raise ValueError(f"Unknown operation: {op}")


def ieee_result_bits(op: str, a_bits: int, b_bits: int) -> int:
    """
    Calculate the expected IEEE-754 binary32 result.

    Inputs are first interpreted as binary32. The operation is performed
    in Python, then the result is rounded back to binary32.
    """
    a = bits32_to_float(a_bits)
    b = bits32_to_float(b_bits)

    try:
        result = reference(op, a, b)
        return float_to_bits32(result)
    except OverflowError:
        # Overflow during conversion to binary32.
        return float_to_bits32(math.copysign(float("inf"), result))


def random_normal_bits() -> int:
    """Generate a random finite normal binary32 value."""
    sign = random.getrandbits(1)
    exponent = random.randint(1, 254)
    fraction = random.getrandbits(23)
    return (sign << 31) | (exponent << 23) | fraction


def random_any_bits() -> int:
    """Generate any 32-bit IEEE-754 bit pattern."""
    return random.getrandbits(32)


def generate_edge_cases():
    """Important deterministic IEEE-754 test cases."""
    pos_zero = 0x00000000
    neg_zero = 0x80000000
    pos_inf = 0x7F800000
    neg_inf = 0xFF800000
    qnan = 0x7FC00000

    # Smallest/largest positive subnormal
    min_sub = 0x00000001
    max_sub = 0x007FFFFF

    # Smallest/largest positive normal
    min_normal = 0x00800000
    max_normal = 0x7F7FFFFF

    # Some ordinary values
    one = 0x3F800000
    two = 0x40000000
    three = 0x40400000
    half = 0x3F000000
    neg_one = 0xBF800000
    neg_two = 0xC0000000
    ten = 0x41200000
    hundred = 0x42C80000

    cases = []

    def add(op, a, b):
        cases.append((op, a, b, ieee_result_bits(op, a, b)))

    # Basic arithmetic
    add("ADD", one, two)
    add("ADD", two, three)
    add("ADD", neg_one, two)
    add("ADD", neg_two, neg_one)
    add("SUB", three, one)
    add("SUB", one, three)
    add("SUB", one, one)
    add("SUB", one, neg_one)
    add("MUL", two, three)
    add("MUL", neg_two, three)
    add("MUL", neg_two, neg_two)
    add("MUL", half, two)
    add("DIV", ten, two)
    add("DIV", ten, three)
    add("DIV", neg_two, two)
    add("DIV", two, neg_two)

    # Zero / signed zero
    add("ADD", pos_zero, pos_zero)
    add("ADD", pos_zero, neg_zero)
    add("ADD", neg_zero, neg_zero)
    add("SUB", pos_zero, pos_zero)
    add("SUB", neg_zero, pos_zero)
    add("SUB", pos_zero, neg_zero)
    add("MUL", pos_zero, two)
    add("MUL", neg_zero, two)
    add("DIV", pos_zero, two)
    add("DIV", neg_zero, two)
    add("DIV", one, pos_zero)
    add("DIV", one, neg_zero)
    add("DIV", pos_zero, pos_zero)

    # Infinity
    add("ADD", pos_inf, one)
    add("ADD", neg_inf, one)
    add("ADD", pos_inf, neg_inf)
    add("SUB", pos_inf, one)
    add("SUB", pos_inf, pos_inf)
    add("MUL", pos_inf, two)
    add("MUL", neg_inf, two)
    add("MUL", pos_inf, pos_zero)
    add("DIV", pos_inf, two)
    add("DIV", neg_inf, two)
    add("DIV", pos_inf, pos_inf)

    # NaN propagation / operations involving NaN
    add("ADD", qnan, one)
    add("SUB", qnan, one)
    add("MUL", qnan, one)
    add("DIV", qnan, one)

    # Subnormal boundaries
    add("ADD", min_sub, min_sub)
    add("ADD", max_sub, min_sub)
    add("SUB", min_normal, min_sub)
    add("MUL", min_sub, two)
    add("DIV", min_sub, two)

    # Large/small values
    add("ADD", max_normal, max_normal)
    add("MUL", max_normal, two)
    add("DIV", min_normal, two)
    add("MUL", min_normal, min_normal)

    # Some exact decimal examples
    add("ADD", ten, hundred)
    add("SUB", hundred, ten)
    add("MUL", ten, hundred)
    add("DIV", hundred, ten)

    return cases


def generate_random_cases(count: int, include_special: bool = False):
    cases = []

    for _ in range(count):
        op = random.choice(list(OPS.keys()))

        if include_special:
            a_bits = random_any_bits()
            b_bits = random_any_bits()
        else:
            a_bits = random_normal_bits()
            b_bits = random_normal_bits()

        # Avoid an overwhelming number of random divisions by zero unless
        # special testing is explicitly requested.
        if op == "DIV" and not include_special:
            while (b_bits & 0x7FFFFFFF) == 0:
                b_bits = random_normal_bits()

        result_bits = ieee_result_bits(op, a_bits, b_bits)
        cases.append((op, a_bits, b_bits, result_bits))

    return cases


def write_vectors(cases, output_path: Path):
    """
    Write a simple whitespace-separated format:

        OP  A_HEX  B_HEX  EXPECTED_HEX

    Example:
        ADD 3F800000 40000000 40400000
    """
    with output_path.open("w") as f:
        f.write("# IEEE-754 binary32 test vectors\n")
        f.write("# operation A B expected\n")

        for op, a, b, expected in cases:
            f.write(
                f"{op:>3} "
                f"{a:08X} "
                f"{b:08X} "
                f"{expected:08X}\n"
            )


def write_verilog_cases(cases, output_path: Path):
    """
    Generate a SystemVerilog include file containing a packed array.

    This is useful if you want to include the vectors directly in a
    SystemVerilog testbench.
    """
    with output_path.open("w") as f:
        f.write("// Auto-generated IEEE-754 binary32 test vectors\n")
        f.write("// {operation, A, B, expected}\n\n")
        f.write("initial begin\n")

        for i, (op, a, b, expected) in enumerate(cases):
            f.write(
                f"    // Test {i}\n"
                f"    test_operation("
                f"2'd{OPS[op]}, "
                f"32'h{a:08X}, "
                f"32'h{b:08X}, "
                f"32'h{expected:08X});\n"
            )

        f.write("end\n")


def main():
    parser = argparse.ArgumentParser(
        description="Generate IEEE-754 single-precision FPU test vectors."
    )
    parser.add_argument(
        "--count",
        type=int,
        default=1000,
        help="Number of random tests per generated set (default: 1000)",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=12345,
        help="Random seed for reproducibility (default: 12345)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("fp_tests.txt"),
        help="Output vector file (default: fp_tests.txt)",
    )
    parser.add_argument(
        "--verilog",
        type=Path,
        default=None,
        help="Optional SystemVerilog test file to generate",
    )
    parser.add_argument(
        "--special-random",
        action="store_true",
        help="Also generate random bit patterns including NaN/Inf/subnormals",
    )

    args = parser.parse_args()

    if args.count < 0:
        parser.error("--count must be >= 0")

    random.seed(args.seed)

    edge_cases = generate_edge_cases()
    normal_random = generate_random_cases(args.count, include_special=False)

    cases = edge_cases + normal_random

    if args.special_random:
        special_random = generate_random_cases(args.count, include_special=True)
        cases.extend(special_random)

    write_vectors(cases, args.output)

    if args.verilog is not None:
        write_verilog_cases(cases, args.verilog)

    print(f"Generated {len(cases)} test vectors.")
    print(f"Vectors: {args.output}")

    if args.verilog is not None:
        print(f"SystemVerilog: {args.verilog}")


if __name__ == "__main__":
    main()
