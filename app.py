from flask import Flask, render_template, request, redirect, session, Response, url_for, jsonify
import pyodbc
import hashlib
import os
import tempfile

app = Flask(__name__)
app.secret_key = "technova_secret_key"


def get_conn():
    return pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        r"SERVER=DESKTOP-THU75VC\SQLEXPRESS;"
        "DATABASE=Technova;"
        "Trusted_Connection=yes;"
    )

# =========================
# 🛒 SQL sản phẩm từ bài 2
# Giữ riêng để không làm hỏng database tài khoản của bài 1.
# Nếu bạn đã gộp tất cả bảng vào cùng database, đổi product_database thành "Technova1".
# =========================
PRODUCT_DB_CONFIG = {
    "server": r"DESKTOP-THU75VC\SQLEXPRESS",
    "database": "Technova",
    "driver": "{ODBC Driver 17 for SQL Server}"
}


def get_product_conn():
    return pyodbc.connect(
        f"DRIVER={PRODUCT_DB_CONFIG['driver']};"
        f"SERVER={PRODUCT_DB_CONFIG['server']};"
        f"DATABASE={PRODUCT_DB_CONFIG['database']};"
        "Trusted_Connection=yes;"
    )


def format_price(price):
    return f"{int(price):,}".replace(",", ".") + " đ"


def safe_float(value, default=0):
    try:
        return float(value)
    except Exception:
        return default

def get_last_name(full_name):
    if not full_name:
        return "User"
    return full_name.strip().split()[-1]


# =========================
# 🖼 AVATAR ĐÃ CROP TỪ SQL
# =========================
@app.route("/avatar/<int:account_id>")
def avatar(account_id):
    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT avatar_data, avatar_mime
        FROM customer_profiles
        WHERE account_id = ?
    """, (account_id,))

    row = cursor.fetchone()
    conn.close()

    if not row or not row[0]:
        return redirect(url_for("static", filename="img/user.png"))

    return Response(row[0], mimetype=row[1])


# =========================
# 🖼 AVATAR GỐC TỪ SQL
# =========================
@app.route("/avatar-original/<int:account_id>")
def avatar_original(account_id):
    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT avatar_original_data, avatar_original_mime
        FROM customer_profiles
        WHERE account_id = ?
    """, (account_id,))

    row = cursor.fetchone()
    conn.close()

    if not row or not row[0]:
        return redirect(url_for("avatar", account_id=account_id))

    return Response(row[0], mimetype=row[1])


# =========================
# 🏠 TRANG CHỦ
# =========================
@app.route("/")
def index():
    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT 
            v.product_id,
            p.name + ' ' + v.storage AS name,
            v.price,
            v.image_main
        FROM product_variants_phone v
        JOIN products_phone p ON v.product_id = p.id
    """)

    columns = [col[0] for col in cursor.description]
    phones = [dict(zip(columns, row)) for row in cursor.fetchall()]

    conn.close()

    return render_template("index.html", phones=phones)


# =========================
# 🔐 ĐĂNG NHẬP
# =========================
# =========================
# 🔐 ĐĂNG NHẬP
# =========================
@app.route("/signin", methods=["GET", "POST"])
def signin():
    error_message = None

    if request.method == "POST":
        login_input = request.form.get("login_input", "").strip()
        password = request.form.get("password", "").strip()

        if not login_input:
            error_message = "Email hoặc số điện thoại không được để trống."
            return render_template("signin.html", error_message=error_message)

        if not password:
            error_message = "Mật khẩu không được để trống."
            return render_template("signin.html", error_message=error_message)

        password_md5 = hashlib.md5(password.encode("utf-8")).hexdigest()

        conn = get_conn()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT 
                a.id,
                a.email,
                a.phone,
                p.full_name,
                p.gender
            FROM accounts a
            JOIN customer_profiles p ON a.id = p.account_id
            WHERE (a.email = ? OR a.phone = ?)
              AND a.password_md5 = ?
              AND a.status = 'active'
        """, (login_input, login_input, password_md5))

        user = cursor.fetchone()
        conn.close()

        if not user:
            error_message = "Tài khoản hoặc mật khẩu không đúng. Vui lòng nhập lại."
            return render_template("signin.html", error_message=error_message)

        # Không đăng nhập ngay tại đây
        # Chỉ lưu tạm thông tin đăng nhập để chờ OTP
        session["pending_signin"] = {
            "account_id": user[0],
            "email": user[1],
            "phone": user[2],
            "full_name": user[3],
            "last_name": get_last_name(user[3]),
            "gender": user[4]
        }

        return redirect("/otp?from=signin")

    return render_template("signin.html", error_message=error_message)


# =========================
# ✅ XÁC NHẬN OTP ĐĂNG NHẬP
# =========================
@app.route("/verify-signin-otp", methods=["POST"])
def verify_signin_otp():
    otp_code = request.form.get("otp_code")

    if otp_code != "279279":
        return redirect("/otp?from=signin&error=1")

    pending = session.get("pending_signin")

    if not pending:
        return redirect("/signin")

    session["account_id"] = pending["account_id"]
    session["email"] = pending["email"]
    session["phone"] = pending["phone"]
    session["full_name"] = pending["full_name"]
    session["last_name"] = pending["last_name"]
    session["gender"] = pending["gender"]

    session.pop("pending_signin", None)

    return redirect("/")
# =========================
# 📝 ĐĂNG KÝ
# =========================
@app.route("/signup", methods=["GET", "POST"])
def signup():
    error_message = None

    if request.method == "POST":
        full_name = request.form.get("full_name", "").strip()
        email = request.form.get("email", "").strip()
        phone = request.form.get("phone", "").strip()
        gender = request.form.get("gender", "Nam")
        date_of_birth = request.form.get("date_of_birth", "")
        password = request.form.get("password", "")
        agree_terms = request.form.get("agree_terms")

        form_data = {
            "full_name": full_name,
            "email": email,
            "phone": phone,
            "gender": gender,
            "date_of_birth": date_of_birth,
            "password": password,
            "agree_terms": True if agree_terms else False
        }

        conn = get_conn()
        cursor = conn.cursor()

        cursor.execute("SELECT id FROM accounts WHERE email = ?", (email,))
        if cursor.fetchone():
            conn.close()
            form_data["email"] = ""
            return render_template(
                "signup.html",
                error_message="Email này đã tồn tại trong hệ thống. Vui lòng sử dụng email khác.",
                form_data=form_data
            )

        cursor.execute("SELECT id FROM accounts WHERE phone = ?", (phone,))
        if cursor.fetchone():
            conn.close()
            form_data["phone"] = ""
            return render_template(
                "signup.html",
                error_message="Số điện thoại này đã tồn tại trong hệ thống. Vui lòng sử dụng số điện thoại khác.",
                form_data=form_data
            )

        conn.close()

        avatar_temp_path = None
        avatar_mime = None

        avatar_original_temp_path = None
        avatar_original_mime = None

        avatar_file = request.files.get("avatar")
        avatar_original_file = request.files.get("avatar_original")

        # Ảnh đã crop
        if avatar_file and avatar_file.filename:
            fd, avatar_temp_path = tempfile.mkstemp(suffix=".jpg")
            os.close(fd)
            avatar_file.save(avatar_temp_path)
            avatar_mime = avatar_file.mimetype

        # Ảnh gốc
        if avatar_original_file and avatar_original_file.filename:
            ext = os.path.splitext(avatar_original_file.filename)[1] or ".jpg"
            fd, avatar_original_temp_path = tempfile.mkstemp(suffix=ext)
            os.close(fd)
            avatar_original_file.save(avatar_original_temp_path)
            avatar_original_mime = avatar_original_file.mimetype

        session["pending_signup"] = {
            "full_name": full_name,
            "email": email,
            "phone": phone,
            "gender": gender,
            "date_of_birth": date_of_birth,
            "password": password,
            "agree_terms": True if agree_terms else False,

            "avatar_temp_path": avatar_temp_path,
            "avatar_mime": avatar_mime,

            "avatar_original_temp_path": avatar_original_temp_path,
            "avatar_original_mime": avatar_original_mime
        }

        return redirect("/otp?from=signup")

    pending = session.get("pending_signup")

    if pending:
        return render_template("signup.html", form_data=pending)

    return render_template("signup.html", form_data={})


# =========================
# ✅ XÁC NHẬN OTP ĐĂNG KÝ
# =========================
@app.route("/verify-signup-otp", methods=["POST"])
def verify_signup_otp():
    otp_code = request.form.get("otp_code")

    if otp_code != "279279":
        return redirect("/otp?from=signup&error=1")

    pending = session.get("pending_signup")

    if not pending:
        return redirect("/signup")

    full_name = pending["full_name"]
    email = pending["email"]
    phone = pending["phone"]
    gender = pending["gender"]
    date_of_birth = pending["date_of_birth"]
    password = pending["password"]

    avatar_data = None
    avatar_mime = pending.get("avatar_mime")

    avatar_original_data = None
    avatar_original_mime = pending.get("avatar_original_mime")

    avatar_temp_path = pending.get("avatar_temp_path")
    avatar_original_temp_path = pending.get("avatar_original_temp_path")

    # Đọc ảnh đã crop
    if avatar_temp_path and os.path.exists(avatar_temp_path):
        with open(avatar_temp_path, "rb") as f:
            avatar_data = pyodbc.Binary(f.read())

        os.remove(avatar_temp_path)

    # Đọc ảnh gốc
    if avatar_original_temp_path and os.path.exists(avatar_original_temp_path):
        with open(avatar_original_temp_path, "rb") as f:
            avatar_original_data = pyodbc.Binary(f.read())

        os.remove(avatar_original_temp_path)

    # Nếu có ảnh gốc nhưng chưa có ảnh crop thì dùng tạm ảnh gốc làm avatar hiển thị
    if avatar_data is None and avatar_original_data is not None:
        avatar_data = avatar_original_data
        avatar_mime = avatar_original_mime

    password_md5 = hashlib.md5(password.encode("utf-8")).hexdigest()

    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO accounts
        (
            username,
            email,
            phone,
            password_md5,
            role,
            status
        )
        OUTPUT INSERTED.id
        VALUES
        (
            ?, ?, ?, ?,
            'customer',
            'active'
        )
    """, (
        email,
        email,
        phone,
        password_md5
    ))

    account_id = cursor.fetchone()[0]

    cursor.execute("""
        INSERT INTO customer_profiles
        (
            account_id,
            full_name,
            gender,
            date_of_birth,
            avatar_data,
            avatar_mime,
            avatar_original_data,
            avatar_original_mime
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        account_id,
        full_name,
        gender,
        date_of_birth,
        avatar_data,
        avatar_mime,
        avatar_original_data,
        avatar_original_mime
    ))

    conn.commit()
    conn.close()

    session.pop("pending_signup", None)

    session["account_id"] = account_id
    session["full_name"] = full_name
    session["last_name"] = get_last_name(full_name)
    session["gender"] = gender

    return redirect("/")


# =========================
# 🔑 QUÊN MẬT KHẨU
# =========================
@app.route("/forgetpassword", methods=["GET", "POST"])
def forgetpassword():
    if request.method == "POST":
        login_input = request.form.get("login_input", "").strip()

        if not login_input:
            return render_template(
                "forgetpassword.html",
                error_message="Email hoặc số điện thoại không được để trống."
            )

        conn = get_conn()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT id
            FROM accounts
            WHERE (email = ? OR phone = ?)
              AND status = 'active'
        """, (login_input, login_input))

        row = cursor.fetchone()
        conn.close()

        if not row:
            return render_template(
                "forgetpassword.html",
                error_message="Tài khoản không tồn tại trong hệ thống."
            )

        session["reset_account_id"] = row[0]

        return redirect("/otp?from=forgetpassword")

    return render_template("forgetpassword.html")


@app.route("/resetpassword", methods=["GET", "POST"])
def resetpassword():
    if not session.get("reset_account_id"):
        return redirect("/forgetpassword")

    if request.method == "POST":
        new_password = request.form.get("new_password", "").strip()
        confirm_password = request.form.get("confirm_password", "").strip()

        if not new_password:
            return render_template(
                "resetpassword.html",
                error_message="Mật khẩu mới không được để trống."
            )

        if len(new_password) < 8:
            return render_template(
                "resetpassword.html",
                error_message="Mật khẩu phải bao gồm ít nhất 8 ký tự."
            )

        if new_password != confirm_password:
            return render_template(
                "resetpassword.html",
                error_message="Mật khẩu xác nhận không khớp, vui lòng nhập lại."
            )

        new_password_md5 = hashlib.md5(new_password.encode("utf-8")).hexdigest()

        conn = get_conn()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT password_md5
            FROM accounts
            WHERE id = ?
        """, (session["reset_account_id"],))

        row = cursor.fetchone()

        if not row:
            conn.close()
            return redirect("/forgetpassword")

        old_password_md5 = row[0]

        if new_password_md5 == old_password_md5:
            conn.close()
            return render_template(
                "resetpassword.html",
                error_message="Mật khẩu mới không được trùng với mật khẩu cũ. Vui lòng chọn mật khẩu khác."
            )

        cursor.execute("""
            UPDATE accounts
            SET password_md5 = ?
            WHERE id = ?
        """, (new_password_md5, session["reset_account_id"]))

        conn.commit()
        conn.close()

        session.pop("reset_account_id", None)

        return redirect("/passwordsuccess")

    return render_template("resetpassword.html")


@app.route("/passwordsuccess")
def passwordsuccess():
    return render_template("passwordsuccess.html")


# =========================
# 👤 THÔNG TIN TÀI KHOẢN
# =========================
@app.route("/infor", methods=["GET", "POST"])
def infor():
    if not session.get("account_id"):
        return redirect("/signin")

    account_id = session["account_id"]

    if request.method == "POST":
        import re
        from datetime import datetime, date

        email = request.form.get("email", "").strip()
        phone = request.form.get("phone", "").strip()
        date_of_birth = request.form.get("date_of_birth", "").strip()

        full_name = request.form.get("full_name", "").strip()
        gender = request.form.get("gender", "Nam")

        avatar_file = request.files.get("avatar")
        avatar_original_file = request.files.get("avatar_original")

        conn = get_conn()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT 
                a.email,
                a.phone,
                p.date_of_birth
            FROM accounts a
            JOIN customer_profiles p ON a.id = p.account_id
            WHERE a.id = ?
        """, (account_id,))

        current_account = cursor.fetchone()

        if not current_account:
            conn.close()
            return redirect("/signin")

        current_email = current_account[0]
        current_phone = current_account[1]
        current_birth = current_account[2]

        if current_birth:
            current_birth = str(current_birth)
        else:
            current_birth = ""

        if not email:
            email = current_email

        if not phone:
            phone = current_phone

        if not date_of_birth:
            date_of_birth = current_birth

        email_regex = r"^[^\s@]+@[^\s@]+\.[^\s@]+$"

        if not re.match(email_regex, email):
            conn.close()
            return redirect("/infor?email_error=invalid")

        phone_regex = r"^0[0-9]{9}$"

        if not re.match(phone_regex, phone):
            conn.close()
            return redirect("/infor?phone_error=invalid")

        if date_of_birth:
            try:
                birth_date = datetime.strptime(date_of_birth, "%Y-%m-%d").date()

                if birth_date > date.today():
                    conn.close()
                    return redirect("/infor?birth_error=invalid")

            except ValueError:
                conn.close()
                return redirect("/infor?birth_error=invalid")

        cursor.execute("""
            SELECT id
            FROM accounts
            WHERE email = ?
              AND id <> ?
        """, (email, account_id))

        if cursor.fetchone():
            conn.close()
            return redirect("/infor?email_error=exists")

        cursor.execute("""
            SELECT id
            FROM accounts
            WHERE phone = ?
              AND id <> ?
        """, (phone, account_id))

        if cursor.fetchone():
            conn.close()
            return redirect("/infor?phone_error=exists")

        conn.close()

        old_pending = session.get("pending_infor_update", {})

        avatar_temp_path = old_pending.get("avatar_temp_path")
        avatar_mime = old_pending.get("avatar_mime")

        avatar_original_temp_path = old_pending.get("avatar_original_temp_path")
        avatar_original_mime = old_pending.get("avatar_original_mime")

        if avatar_file and avatar_file.filename:
            if avatar_temp_path and os.path.exists(avatar_temp_path):
                os.remove(avatar_temp_path)

            fd, avatar_temp_path = tempfile.mkstemp(suffix=".jpg")
            os.close(fd)
            avatar_file.save(avatar_temp_path)
            avatar_mime = avatar_file.mimetype

        if avatar_original_file and avatar_original_file.filename:
            if avatar_original_temp_path and os.path.exists(avatar_original_temp_path):
                os.remove(avatar_original_temp_path)

            ext = os.path.splitext(avatar_original_file.filename)[1] or ".jpg"
            fd, avatar_original_temp_path = tempfile.mkstemp(suffix=ext)
            os.close(fd)
            avatar_original_file.save(avatar_original_temp_path)
            avatar_original_mime = avatar_original_file.mimetype

        session["pending_infor_update"] = {
            "email": email,
            "phone": phone,
            "date_of_birth": date_of_birth,
            "full_name": full_name,
            "gender": gender,
            "avatar_temp_path": avatar_temp_path,
            "avatar_mime": avatar_mime,
            "avatar_original_temp_path": avatar_original_temp_path,
            "avatar_original_mime": avatar_original_mime
        }

        return redirect("/otp?from=infor_save")

    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT 
            a.email,
            a.phone,
            p.full_name,
            p.gender,
            p.date_of_birth
        FROM accounts a
        JOIN customer_profiles p ON a.id = p.account_id
        WHERE a.id = ?
    """, (account_id,))

    row = cursor.fetchone()
    conn.close()

    if not row:
        return redirect("/signin")

    db_birth = ""

    if row[4]:
        db_birth = str(row[4])

    pending = session.get("pending_infor_update")

    if pending:
        email = pending.get("email", row[0])
        phone = pending.get("phone", row[1])
        full_name = pending.get("full_name", row[2])
        gender = pending.get("gender", row[3])
        date_of_birth = pending.get("date_of_birth", db_birth)

        if pending.get("avatar_temp_path") and os.path.exists(pending.get("avatar_temp_path")):
            avatar_url = url_for("pending_avatar_preview")
        else:
            avatar_url = url_for("avatar", account_id=account_id)
    else:
        email = row[0]
        phone = row[1]
        full_name = row[2]
        gender = row[3]
        date_of_birth = db_birth
        avatar_url = url_for("avatar", account_id=account_id)

    return render_template(
        "infor.html",
        pending_new_email="",
        pending_new_phone="",
        email=email,
        phone=phone,
        full_name=full_name,
        gender=gender,
        date_of_birth=date_of_birth,
        avatar_url=avatar_url,
        avatar_original_url=url_for("avatar_original", account_id=account_id)
    )

@app.route("/pending-avatar-preview")
def pending_avatar_preview():
    if not session.get("account_id"):
        return redirect("/signin")

    pending = session.get("pending_infor_update")

    if not pending:
        return redirect(url_for("avatar", account_id=session["account_id"]))

    avatar_temp_path = pending.get("avatar_temp_path")
    avatar_mime = pending.get("avatar_mime") or "image/jpeg"

    if not avatar_temp_path or not os.path.exists(avatar_temp_path):
        return redirect(url_for("avatar", account_id=session["account_id"]))

    with open(avatar_temp_path, "rb") as f:
        avatar_data = f.read()

    return Response(avatar_data, mimetype=avatar_mime)

@app.route("/verify-infor-save-otp", methods=["POST"])
def verify_infor_save_otp():
    if not session.get("account_id"):
        return redirect("/signin")

    otp_code = request.form.get("otp_code", "").strip()

    if otp_code != "279279":
        return redirect("/otp?from=infor_save&error=1")

    pending = session.get("pending_infor_update")

    if not pending:
        return redirect("/infor")

    import re
    from datetime import datetime, date

    account_id = session["account_id"]

    email = pending.get("email", "").strip()
    phone = pending.get("phone", "").strip()
    date_of_birth = pending.get("date_of_birth", "").strip()
    full_name = pending.get("full_name", "").strip()
    gender = pending.get("gender", "Nam")

    email_regex = r"^[^\s@]+@[^\s@]+\.[^\s@]+$"
    phone_regex = r"^0[0-9]{9}$"

    if not re.match(email_regex, email):
        return redirect("/infor?email_error=invalid")

    if not re.match(phone_regex, phone):
        return redirect("/infor?phone_error=invalid")

    if date_of_birth:
        try:
            birth_date = datetime.strptime(date_of_birth, "%Y-%m-%d").date()

            if birth_date > date.today():
                return redirect("/infor?birth_error=invalid")

        except ValueError:
            return redirect("/infor?birth_error=invalid")
    else:
        birth_date = None

    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id
        FROM accounts
        WHERE email = ?
          AND id <> ?
    """, (email, account_id))

    if cursor.fetchone():
        conn.close()
        return redirect("/infor?email_error=exists")

    cursor.execute("""
        SELECT id
        FROM accounts
        WHERE phone = ?
          AND id <> ?
    """, (phone, account_id))

    if cursor.fetchone():
        conn.close()
        return redirect("/infor?phone_error=exists")

    cursor.execute("""
        UPDATE accounts
        SET email = ?,
            username = ?,
            phone = ?
        WHERE id = ?
    """, (
        email,
        email,
        phone,
        account_id
    ))

    avatar_temp_path = pending.get("avatar_temp_path")
    avatar_mime = pending.get("avatar_mime")

    avatar_original_temp_path = pending.get("avatar_original_temp_path")
    avatar_original_mime = pending.get("avatar_original_mime")

    if avatar_temp_path and os.path.exists(avatar_temp_path):
        with open(avatar_temp_path, "rb") as f:
            avatar_data = f.read()

        if avatar_original_temp_path and os.path.exists(avatar_original_temp_path):
            with open(avatar_original_temp_path, "rb") as f:
                avatar_original_data = f.read()

            cursor.execute("""
                UPDATE customer_profiles
                SET full_name = ?,
                    gender = ?,
                    date_of_birth = ?,
                    avatar_data = ?,
                    avatar_mime = ?,
                    avatar_original_data = ?,
                    avatar_original_mime = ?
                WHERE account_id = ?
            """, (
                full_name,
                gender,
                birth_date,
                pyodbc.Binary(avatar_data),
                avatar_mime,
                pyodbc.Binary(avatar_original_data),
                avatar_original_mime,
                account_id
            ))

        else:
            cursor.execute("""
                UPDATE customer_profiles
                SET full_name = ?,
                    gender = ?,
                    date_of_birth = ?,
                    avatar_data = ?,
                    avatar_mime = ?
                WHERE account_id = ?
            """, (
                full_name,
                gender,
                birth_date,
                pyodbc.Binary(avatar_data),
                avatar_mime,
                account_id
            ))

    else:
        cursor.execute("""
            UPDATE customer_profiles
            SET full_name = ?,
                gender = ?,
                date_of_birth = ?
            WHERE account_id = ?
        """, (
            full_name,
            gender,
            birth_date,
            account_id
        ))

    conn.commit()
    conn.close()

    if avatar_temp_path and os.path.exists(avatar_temp_path):
        os.remove(avatar_temp_path)

    if avatar_original_temp_path and os.path.exists(avatar_original_temp_path):
        os.remove(avatar_original_temp_path)

    session["email"] = email
    session["phone"] = phone
    session["full_name"] = full_name
    session["last_name"] = get_last_name(full_name)
    session["gender"] = gender

    session.pop("pending_infor_update", None)
    session.pop("pending_change_email", None)
    session.pop("pending_change_phone", None)

    return redirect("/infor")

@app.route("/request-change-phone", methods=["POST"])
def request_change_phone():
    if not session.get("account_id"):
        return {
            "success": False,
            "message": "Bạn cần đăng nhập để thay đổi số điện thoại."
        }, 401

    data = request.get_json()
    new_phone = data.get("new_phone", "").strip() if data else ""

    if not new_phone:
        return {
            "success": False,
            "message": "Số điện thoại mới không được để trống."
        }

    import re
    phone_regex = r"^0[0-9]{9}$"

    if not re.match(phone_regex, new_phone):
        return {
            "success": False,
            "message": "Số điện thoại phải gồm 10 số và bắt đầu bằng 0."
        }

    account_id = session["account_id"]

    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT phone
        FROM accounts
        WHERE id = ?
    """, (account_id,))

    row = cursor.fetchone()

    if not row:
        conn.close()
        return {
            "success": False,
            "message": "Không tìm thấy tài khoản."
        }

    old_phone = row[0]

    if new_phone == old_phone:
        conn.close()
        return {
            "success": False,
            "message": "Số điện thoại mới không được trùng với số hiện tại."
        }

    cursor.execute("""
        SELECT id
        FROM accounts
        WHERE phone = ?
          AND id <> ?
    """, (new_phone, account_id))

    if cursor.fetchone():
        conn.close()
        return {
            "success": False,
            "message": "Số điện thoại này đã tồn tại trong hệ thống."
        }

    conn.close()

    session["pending_change_phone"] = {
        "old_phone": old_phone,
        "new_phone": new_phone
    }

    return {
        "success": True,
        "redirect_url": "/otp?from=change_phone"
    }

@app.route("/verify-change-phone-otp", methods=["POST"])
def verify_change_phone_otp():
    otp_code = request.form.get("otp_code")

    if otp_code != "279279":
        return redirect("/otp?from=change_phone&error=1")

    if not session.get("account_id"):
        return redirect("/signin")

    pending = session.get("pending_change_phone")

    if not pending:
        return redirect("/infor")

    account_id = session["account_id"]
    new_phone = pending["new_phone"]

    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id
        FROM accounts
        WHERE phone = ?
          AND id <> ?
    """, (new_phone, account_id))

    if cursor.fetchone():
        conn.close()
        session.pop("pending_change_phone", None)
        return redirect("/infor?phone_error=exists")

    cursor.execute("""
        UPDATE accounts
        SET phone = ?
        WHERE id = ?
    """, (
        new_phone,
        account_id
    ))

    conn.commit()
    conn.close()

    session["phone"] = new_phone
    session.pop("pending_change_phone", None)

    return redirect("/infor?phone_success=1")


@app.route("/logout")
def logout():
    session.clear()
    return redirect("/")


# =========================
# 🔐 OTP
# =========================
# =========================
# 🔐 OTP
# =========================
# =========================
# 🔐 OTP
# =========================
@app.route("/otp")
def otp():
    from_page = request.args.get("from")

    if from_page == "signup":
        back_url = "/signup"
        parent_name = "Đăng ký"
        parent_url = "/signup"
        verify_url = "/verify-signup-otp"

    elif from_page == "forgetpassword":
        back_url = "/forgetpassword"
        parent_name = "Quên mật khẩu"
        parent_url = "/forgetpassword"
        verify_url = "/resetpassword"

    elif from_page == "signin":
        back_url = "/signin"
        parent_name = "Đăng nhập"
        parent_url = "/signin"
        verify_url = "/verify-signin-otp"

    

    elif from_page == "change_email":
        back_url = "/infor?open_email_modal=1"
        parent_name = "Quản lý tài khoản"
        parent_url = "/infor"
        verify_url = "/verify-change-email-otp"

    elif from_page == "change_phone":
        back_url = "/infor?open_phone_modal=1"
        parent_name = "Quản lý tài khoản"
        parent_url = "/infor"
        verify_url = "/verify-change-phone-otp"

    elif from_page == "infor_save":
        back_url = "/infor?keep_pending=1"
        parent_name = "Quản lý tài khoản"
        parent_url = "/infor"
        verify_url = "/verify-infor-save-otp"


    else:
        back_url = "/signin"
        parent_name = "Đăng nhập"
        parent_url = "/signin"
        verify_url = "/verify-signin-otp"

    return render_template(
        "otp.html",
        back_url=back_url,
        parent_name=parent_name,
        parent_url=parent_url,
        verify_url=verify_url
    )

# =========================
# onclick chuyển trang danh mục
# =========================
@app.route("/phones")
def phones():
    return redirect("/products?category=phone")

@app.route("/tablets")
def tablets():
    return redirect("/products?category=tablet")


@app.route("/laptops")
def laptops():
    return redirect("/products?category=laptop")


@app.route("/ipads")
def ipads():
    return redirect("/products?category=ipad")


@app.route("/headphones")
def headphones():
    return redirect("/products?category=audio")


@app.route("/accessories")
def accessories():
    return redirect("/products?category=accessory")


@app.route("/watches")
def watches():
    return redirect("/products?category=watch")


@app.route("/monitors")
def monitors():
    return redirect("/products?category=printer")

@app.route("/change-email", methods=["POST"])
def change_email():
    if not session.get("account_id"):
        return {
            "success": False,
            "message": "Bạn cần đăng nhập để thay đổi email."
        }, 401

    data = request.get_json()
    new_email = data.get("new_email", "").strip() if data else ""

    if not new_email:
        return {
            "success": False,
            "message": "Email mới không được để trống."
        }

    import re
    email_regex = r"^[^\s@]+@[^\s@]+\.[^\s@]+$"

    if not re.match(email_regex, new_email):
        return {
            "success": False,
            "message": "Email không đúng định dạng, vui lòng nhập lại."
        }

    account_id = session["account_id"]

    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT email
        FROM accounts
        WHERE id = ?
    """, (account_id,))

    current = cursor.fetchone()

    if not current:
        conn.close()
        return {
            "success": False,
            "message": "Không tìm thấy tài khoản."
        }

    old_email = current[0]

    if new_email.lower() == old_email.lower():
        conn.close()
        return {
            "success": False,
            "message": "Email mới không được trùng với email hiện tại."
        }

    cursor.execute("""
        SELECT id
        FROM accounts
        WHERE email = ?
          AND id <> ?
    """, (new_email, account_id))

    if cursor.fetchone():
        conn.close()
        return {
            "success": False,
            "message": "Email này đã tồn tại trong hệ thống."
        }

    cursor.execute("""
        UPDATE accounts
        SET email = ?,
            username = ?
        WHERE id = ?
    """, (
        new_email,
        new_email,
        account_id
    ))

    conn.commit()
    conn.close()

    session["email"] = new_email

    return {
        "success": True,
        "message": "Email của bạn đã được cập nhật thành công.",
        "email": new_email
    }

@app.route("/request-change-email", methods=["POST"])
def request_change_email():
    if not session.get("account_id"):
        return {
            "success": False,
            "message": "Bạn cần đăng nhập để thay đổi email."
        }, 401

    data = request.get_json()
    new_email = data.get("new_email", "").strip() if data else ""

    if not new_email:
        return {
            "success": False,
            "message": "Email mới không được để trống."
        }

    import re
    email_regex = r"^[^\s@]+@[^\s@]+\.[^\s@]+$"

    if not re.match(email_regex, new_email):
        return {
            "success": False,
            "message": "Email không đúng định dạng, vui lòng nhập lại."
        }

    account_id = session["account_id"]

    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT email
        FROM accounts
        WHERE id = ?
    """, (account_id,))

    row = cursor.fetchone()

    if not row:
        conn.close()
        return {
            "success": False,
            "message": "Không tìm thấy tài khoản."
        }

    old_email = row[0]

    if new_email.lower() == old_email.lower():
        conn.close()
        return {
            "success": False,
            "message": "Email mới không được trùng với email hiện tại."
        }

    cursor.execute("""
        SELECT id
        FROM accounts
        WHERE email = ?
          AND id <> ?
    """, (new_email, account_id))

    if cursor.fetchone():
        conn.close()
        return {
            "success": False,
            "message": "Email này đã tồn tại trong hệ thống."
        }

    conn.close()

    session["pending_change_email"] = {
        "old_email": old_email,
        "new_email": new_email
    }

    return {
        "success": True,
        "redirect_url": "/otp?from=change_email"
    }

@app.route("/verify-change-email-otp", methods=["POST"])
def verify_change_email_otp():
    otp_code = request.form.get("otp_code")

    if otp_code != "279279":
        return redirect("/otp?from=change_email&error=1")

    if not session.get("account_id"):
        return redirect("/signin")

    pending = session.get("pending_change_email")

    if not pending:
        return redirect("/infor")

    account_id = session["account_id"]
    new_email = pending["new_email"]

    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id
        FROM accounts
        WHERE email = ?
          AND id <> ?
    """, (new_email, account_id))

    if cursor.fetchone():
        conn.close()
        session.pop("pending_change_email", None)
        return redirect("/infor?email_error=exists")

    cursor.execute("""
        UPDATE accounts
        SET email = ?,
            username = ?
        WHERE id = ?
    """, (
        new_email,
        new_email,
        account_id
    ))

    conn.commit()
    conn.close()

    session["email"] = new_email
    session.pop("pending_change_email", None)

    return redirect("/infor?email_success=1")


# =========================
# 🛒 TRANG SẢN PHẨM - giao diện thêm từ bài 2
# =========================
@app.route("/cart")
def cart():
    return render_template("cart.html")


@app.route("/products")
def products_page():
    return render_template("products.html")


@app.route("/detail")
def product_detail_page():
    return render_template("product_detail.html")


@app.route("/api/check-product-db")
def check_product_db():
    try:
        conn = get_product_conn()
        cursor = conn.cursor()
        cursor.execute("SELECT DB_NAME() AS database_name")
        row = cursor.fetchone()
        conn.close()
        return jsonify({"connected": True, "database": row.database_name})
    except Exception as error:
        return jsonify({"connected": False, "error": str(error)}), 500


@app.route("/api/products")
def get_products_api():
    try:
        conn = get_product_conn()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT
                id,
                name,
                category,
                brand,
                description,
                old_price_text,
                old_price_number,
                discount,
                has_discount,
                rating,
                sold,
                technical_image,
                default_storage_order,
                default_color_order,
                is_flash_sale,
                is_featured,
                is_new
            FROM products
            ORDER BY id
        """)

        product_rows = cursor.fetchall()
        products = []

        for row in product_rows:
            product_id = row.id

            cursor.execute("""
                SELECT storage, ram, price_text, price_number
                FROM product_storages
                WHERE product_id = ?
                ORDER BY display_order
            """, product_id)

            storages = [
                {
                    "storage": storage.storage,
                    "ram": storage.ram,
                    "price": storage.price_text,
                    "priceNumber": int(storage.price_number or 0)
                }
                for storage in cursor.fetchall()
            ]

            cursor.execute("""
                SELECT id, color_name, color_code, main_image AS image
                FROM product_colors
                WHERE product_id = ?
                ORDER BY display_order
            """, product_id)

            colors = []
            for color in cursor.fetchall():
                cursor.execute("""
                    SELECT image_url AS image
                    FROM product_color_images
                    WHERE color_id = ?
                    ORDER BY display_order
                """, color.id)

                gallery = [gallery.image for gallery in cursor.fetchall()]

                colors.append({
                    "name": color.color_name,
                    "code": color.color_code,
                    "image": color.image,
                    "gallery": gallery
                })

            cursor.execute("""
                SELECT id, title
                FROM product_spec_groups
                WHERE product_id = ?
                ORDER BY display_order
            """, product_id)

            full_specifications = []
            for group in cursor.fetchall():
                cursor.execute("""
                    SELECT label, value
                    FROM product_spec_items
                    WHERE group_id = ?
                    ORDER BY display_order
                """, group.id)

                full_specifications.append({
                    "title": group.title,
                    "items": [
                        {"label": item.label, "value": item.value}
                        for item in cursor.fetchall()
                    ]
                })

            cursor.execute("""
                SELECT reviewer_name, rating, comment
                FROM product_reviews
                WHERE product_id = ?
                ORDER BY id
            """, product_id)

            reviews = [
                {
                    "user": review.reviewer_name,
                    "rating": int(review.rating or 0),
                    "comment": review.comment
                }
                for review in cursor.fetchall()
            ]

            default_storage_index = (row.default_storage_order or 1) - 1
            default_color_index = (row.default_color_order or 1) - 1

            default_storage = storages[default_storage_index] if len(storages) > default_storage_index else None
            default_color = colors[default_color_index] if len(colors) > default_color_index else None

            specs = []
            if default_storage:
                if default_storage.get("storage"):
                    specs.append(default_storage["storage"].replace(" ", ""))
                if default_storage.get("ram"):
                    specs.append(default_storage["ram"] + " RAM")

            products.append({
                "id": row.id,
                "name": row.name,
                "category": row.category,
                "brand": row.brand,
                "desc": row.description,
                "price": default_storage["price"] if default_storage else "",
                "priceNumber": default_storage["priceNumber"] if default_storage else 0,
                "oldPrice": row.old_price_text or "",
                "discount": row.discount or "",
                "hasDiscount": bool(row.has_discount),
                "storages": storages,
                "colors": colors,
                "specs": specs,
                "fullSpecifications": full_specifications,
                "image": default_color["image"] if default_color else "",
                "technicalImage": row.technical_image or "",
                "rating": safe_float(row.rating),
                "sold": int(row.sold or 0),
                "reviews": reviews,
                "isFlashSale": bool(row.is_flash_sale),
                "isFeatured": bool(row.is_featured),
                "isNew": bool(row.is_new)
            })

        conn.close()
        return jsonify(products)

    except Exception as error:
        print("Lỗi API sản phẩm:", error, flush=True)
        return jsonify({
            "message": "Không thể lấy dữ liệu sản phẩm. Kiểm tra PRODUCT_DB_CONFIG và các bảng sản phẩm.",
            "error": str(error)
        }), 500

# =========================
# 📱 TRANG CHI TIẾT CŨ CỦA BÀI 1
# =========================
@app.route("/detail/<int:id>")
def detail(id):
    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT * FROM products_phone WHERE id = ?
    """, (id,))
    row = cursor.fetchone()

    if not row:
        conn.close()
        return "Không tìm thấy sản phẩm"

    columns = [col[0] for col in cursor.description]
    phone = dict(zip(columns, row))

    cursor.execute("""
        SELECT id, color_name
        FROM product_colors_phone
        WHERE product_id = ?
    """, (id,))
    colors = [dict(id=r[0], color_name=r[1]) for r in cursor.fetchall()]

    cursor.execute("""
        SELECT color_id, image_url, is_primary
        FROM product_images_phone
        WHERE product_id = ?
        ORDER BY display_order
    """, (id,))
    images = [
        dict(color_id=r[0], image_url=r[1], is_primary=r[2])
        for r in cursor.fetchall()
    ]

    cursor.execute("""
        SELECT color_id, storage, price, image_main
        FROM product_variants_phone
        WHERE product_id = ?
    """, (id,))
    variants = [
        dict(color_id=r[0], storage=r[1], price=r[2], image_main=r[3])
        for r in cursor.fetchall()
    ]

    conn.close()

    return render_template(
        "detail_old.html",
        phone=phone,
        colors=colors,
        images=images,
        variants=variants
    )


if __name__ == "__main__":
    app.run(debug=True)