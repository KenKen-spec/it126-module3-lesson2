# IT 126 - Module 3 Lesson 2: Local Storage and Database Operations

## Analysis Section Answers

1. **What happened to the task titles when you added them to the list?**
   - Ang mga task title ay naidagdag at pansamantalang naimbak sa Dart `List<String>` sa loob ng memory (RAM) ng application.

2. **Why could the application display the tasks while it was running?**
   - Naipakita ito dahil ang UI ay nag-rebuild at binasa ang kasalukuyang data na nakalagay sa in-memory list habang aktibo pa ang proseso ng app.

3. **What happened after the application process ended and the application was relaunched?**
   - Nawala ang lahat ng inilagay na tasks dahil ang in-memory list ay volatile at burado na nang isara ang application process.

4. **Would keeping the list inside a StatefulWidget automatically make the tasks persistent? Explain your answer.**
   - Hindi. Ang `StatefulWidget` ay nagpapanatili lamang ng state habang bukas o aktibo ang widget tree sa memory; hindi nito napi-preserve ang data kapag tuluyang pinatay (terminated) ang app.

5. **What would the application need to do to preserve the tasks between sessions?**
   - Kailangan nitong gumamit ng persistent storage mechanism tulad ng SQLite database, local files, o SharedPreferences upang mailigtas ang data sa non-volatile storage ng device.

6. **If the application eventually stored hundreds or thousands of tasks, what problems might arise from managing all the data manually in memory?**
   - Maaari itong magdulot ng mataas na konsumo sa RAM, mabagal na paghahanap o sorting, at posibleng pag-crash ng app dahil sa memory limits.

7. **How could separating the operations that save and retrieve tasks from the UI make the application easier to maintain?**
   - Pinapaganda nito ang separation of concerns kung saan ang UI ay nakatutok lang sa presentation, habang ang data logic ay nakalagay sa hiwalay na repository o database helper, kaya mas madali itong i-debug at baguhin.

---

## Reflection Section Answers

1. **Why does the application use SQLite instead of relying only on a Dart list?**
   - Ginagamit ang SQLite upang matiyak na ang mga task ay magpapatuloy (persistent) at mananatili kahit isara o i-restart ang application.

2. **What is the purpose of the primary key in the tasks table?**
   - Ang primary key (tulad ng `id`) ay nagbibigay ng natatanging (unique) pagkakakilanlan sa bawat row o record, na mahalaga sa pag-update o pag-delete ng tiyak na task.

3. **How does the repository simplify the UI's interaction with the database?**
   - Inilalagay ng repository ang lahat ng database queries at logic sa isang hiwalay na klase, kaya ang UI ay tatawag lamang ng simpleng methods (tulad ng `create()` o `getAll()`) nang hindi na direktang nagsusulat ng SQL queries.

4. **What would happen if a task were removed from the displayed list but not deleted from SQLite?**
   - Mawawala ito sa paningin ng user pansamantala, ngunit kapag ni-relaunch o ni-refresh ang app, lalabas itong muli dahil nananatili pa rin ito sa database.

5. **If the database schema later needed a new column for task priority, what parts of the application might need to change?**
   - Kailangang baguhin ang `CREATE TABLE` statement (at gumamit ng database version migration/upgrade), ang insert at query functions, ang data models o maps, at ang UI ng application para suportahan ang pagpapakita at pagpili ng priority.