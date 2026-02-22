/*Purpose: Yearly setup of EL (Earned Leave).
What it does:
Assigns 18 days EL for each employee.
Records leave taken during the year.
Updates CARRY_EARN_LEAVE table.
When to run: Once at the beginning of every year (January).*/

EXEC DEV_PROCEDURE.UPDATE_EL_LEAVE_SUMMARY(2025);

/*Purpose: Calculate monthly raw leave/late/absence data.
What it does:
Counts lates, converts 3 late = 1 EL deduction.
Tracks presence, unauthorized absences, pending leaves, tours.
Inserts into MONTH_WISE_LEAVE_COUNT_WITH_DEDUCTION_EL.
When to run: At the end of every month after attendance data is closed.*/

EXEC DEV_PROCEDURE.MONTH_WISE_LEAVE_COUNT_WITH_DEDUCTION('05-2025');

/*Purpose: Track EL deductions across months.
What it does:
Brings forward balances from last month.
Deducts current month’s late penalties → current EL → previous EL → Salary Deduction.
Updates EMP_EL_BALANCE_HISTORY (audit trail).
When to run: After step 2.
(Note: This logic is also merged into step 4, so you can skip this if you use the next one.)*/

EXEC DEV_PROCEDURE.UPDATE_EL_BALANCE_HISTORY('05-2025');

/*Purpose: Main monthly payroll & audit report.
What it does:
Updates HR_MONTHLY_ATTENDANCE_SUMMARY (final salary-impact data).
Updates EMP_EL_BALANCE_HISTORY (deduction trail).
Calculates salary deduction days if no EL balance is left.
When to run: At the end of every month.*/
EXEC DEV_PROCEDURE.PROCESS_MONTHLY_ATTENDANCE('05-2025');


/*The procedure does the following:
Fetches employee master data
RML_ID, EMP_NAME, DEPT_NAME, DESIGNATION, EMP_GROUP, CONCERN.
Pulls attendance + leave summary for the given month
TOTAL_PRESENT_DAYS → Present days count.
TOTAL_LATE_COUNT → How many times late.
LEVEL_DEDUCTED_COUNT_CUR_MONTH → Late-to-EL conversion (deductions).
UNAUTHORIZED_ABSENT → Unapproved absences (from daily attendance).
UNAPPROVED_LEAVE → Pending leave & tour requests.
Calculates leave balances
CURRENT_EARN_LEAVE_BALANCE → Current year EL balance (18 – taken).
PREVIOUS_EARN_LEAVE_BALANCE → Carried-forward EL from last year.
TOTAL_EARN_LEAVE_BALANCE → Sum of current + previous.
LEAVE_BALANCE → Final leave balance after deductions.
Flags payroll deductions
ABSENT_SALARY_REDUCE → Days of salary deduction due to absence.
SALARY_DEDUCTED_FOR_LEAVE → If both current + carry EL = 0, lates push here.
TOTAL_SALARY_DEDUCTIONS → Combined deduction impact.
Handles compliance tracking
JUSTIFICATIONS_SUBMITTED → Count of justification entries.
DISCIPLINARY_ACTION_FLAG → “Y” if excessive late/absences, else “N”.
Upserts (MERGE) into HR_MONTHLY_ATTENDANCE_SUMMARY
If record for (Employee, Month) exists → UPDATE.
If not → INSERT.*/

BEGIN
DEV_PROCEDURE.UPSERT_MONTHLY_ATTENDANCE_SUMMARY('08-2025');
END;
/


--CLOSE_EL_YEAR Purpose: Year-end carry forward.
/*Purpose: Year-end carry forward.

What it does:
Takes unused EL from 2025.
Caps carry forward at 9 days.
Updates CARRY_EARN_LEAVE for 2026.
When to run: December / early January.*/

EXEC DEV_PROCEDURE.CLOSE_EL_YEAR(2025);
--For 2026, run in Jan 2027.




Late policy details

late define হয় কীভাবে (grace time আছে?)
hae ache 15 mininute grace time, tar por late hobe.ei status ta amra "L" diye denote kora ache RML_HR_ATTN_DAILY_PROC table er
Status  column er value te.

late count কি monthly reset নাকি carry হয়?
per month late count reset hoye jabe, carry hobe na.

3 late = 1 day EL deduction ঠিক তো?
yes, 3 late hobe 1 day EL deduction.

EL eligibility

DOJ থেকে কত মাস পরে EL eligible?
DOJ theke 6 month por EL eligible hobe. but er age DOC hote  i mean date of confirmation hote hobe.kintu eita alaready 
amader system define kora ache, EL eligible kina seta tmr RML_HR_EMP_LEAVE_SETUP table already assign kora ache,
jekhane EL eligibility date assign kora ache LEAVE_TYPE column er value EL deoya ache. LEAVE_ASSIGN column er value 1 deoya ache, tar mane EL eligible hobe.
jodi EL leave type assign kora na thake tahole EL eligible hobe na.

probation/contractual/other groups এর rule আলাদা?
sobar jonno same rule apply hobe.

Absent policy

Status ‘A’ কি সবসময় salary deduction? নাকি approved leave থাকলে A ignore হয়?
Salary deduction hobe kon kon reason e seta boli tmk
1. Jodi attendance Status A hoye tahole salary deduction hobe, jodi kono  leave/tour/outdoor-attedence approved na thake seta check korleo hobe reason ta holo 
RML_HR_ATTN_DAILY_PROC table er Status column er value Status leave/tour/outdoor-attedence ei gular approved/pending/denied er upor depend korei Status columne 
value set hoy.so amader just  RML_HR_ATTN_DAILY_PROC table  status column er value check korlei hobe..
2. erpor dhoro kono user EL assign kora nai kintu Late to 3days plus tahole rules wise 3 late = 1 EL je deduction hobar kotha kintu EL assign kora nai 
tai salary deduction hobe.
3. abar dhoro karo jodi rules wise late korar por EL deduction korar por or user EL leave taken kore feleh jodi EL balance 0 hoye jai tahole o salary deduction hobe.

“Outside-Office” + LM approval null = unauthorized absent এটা final নাকি pending?
unauthorized pending  hole best approche hobe r jeta denined kore dibe seta amader  unauthorized absent hobe. karon unauthorized pending hole employee ke bola 
jabe je apni unauthorized absent er jonno appeal korte paren, jodi appeal korte chan tahole amader HR team ke contact korte hobe, 
jara appeal process handle korbe. jodi appeal approve hoy tahole unauthorized absent status ta change hoye jabe approved leave/tour/outdoor-attedence te, 
ar jodi appeal deny hoy tahole unauthorized absent status ta thakbe. so unauthorized absent status ta final hobe jodi appeal deny hoy, ar pending hobe jodi appeal process e thake.
Pending leave/tour/outdoor-attedence এর ক্ষেত্রে কি salary deduction হবে|

later approve হলে কি reverse/update করতে হবে?
na late approve korar way nei .
but amader emon akta way rakte hobe jate kora Pending leave/tour/outdoor-attedence ei gula jodi approved kore seta jeno amader late poliy report gula te oi month er jonno update
hoye jai kinba sync hoye jai.emnity toh daily to akta automatically sync hobei setai sathe kono single user dhoreo sync korte pari setar o ekta way kore rakte hobe.
abar dhoro akta single month er jonno fully data sync korar o akta way korte hobe all user jonno.
tahole amader single user or full month er jonno data sync korar way rakte hobe, jate kore amader report gula te accurate data thake.


Carry forward rule

cap 9 days ঠিক?
hae 9 days cap ache carry forward er jonno.but er thekeo jodi besi kow  besi taken kore fele tahole o carry hobe baki days gula.
trigger ta jemon kaj kore 
CREATE OR REPLACE TRIGGER COUNT_CARRY_EL
    BEFORE INSERT OR UPDATE
    ON LATE_POLICY.CARRY_EARN_LEAVE
    FOR EACH ROW
BEGIN
    IF (:NEW.total_el - :NEW.taken_el) >= 9 THEN
        :NEW.carry_el := 9;
    ELSE
        :NEW.carry_el := :NEW.total_el - :NEW.taken_el;
    END IF;
END;
/

year-end closing date (Dec 31?) এবং next year opening কীভাবে হবে?
year-end closing date December 31 hobe, ar next year opening January 1 hobe.
year-end closing er por amader system automatically next year er data create kore dibe, jekhane amader carry forward EL o set kora thakbe. 
so amader just ensure korte hobe je year-end closing er por system e next year er data properly create hoye jai,
so dekha lagbe per year por amader EL balance o carry forward EL properly set hoye jai.

Payroll output expectation

HR_MONTHLY_ATTENDANCE_SUMMARY তে কোন কোন ফিল্ড final payroll input হবে?
amara report kore dibo ei khan theke dekhe HR manully check kore nite parbe je kon kon field final payroll input hobe.
কোনগুলো শুধু audit/info?
hr jemon ta dekbe same report tai audit team o dekbe same report ta.