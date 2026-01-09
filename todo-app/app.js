// Todo App - Main JavaScript

// In-memory storage for tasks
let tasks = [];

// DOM elements
const taskInput = document.getElementById('task-input');
const addBtn = document.getElementById('add-btn');
const taskList = document.getElementById('task-list');

// Add a new task
function addTask() {
    const text = taskInput.value.trim();

    // Validate: don't add empty tasks
    if (!text) {
        return;
    }

    // Create task object with unique ID
    const task = {
        id: Date.now(),
        text: text,
        completed: false
    };

    // Add to array
    tasks.push(task);

    // Render the task
    renderTask(task);

    // Clear input
    taskInput.value = '';
    taskInput.focus();
}

// Render a single task to the DOM
function renderTask(task) {
    const li = document.createElement('li');
    li.dataset.id = task.id;

    // Task text span
    const taskText = document.createElement('span');
    taskText.className = 'task-text';
    taskText.textContent = task.text;

    // Delete button
    const deleteBtn = document.createElement('button');
    deleteBtn.className = 'delete-btn';
    deleteBtn.textContent = '×';
    deleteBtn.type = 'button';

    li.appendChild(taskText);
    li.appendChild(deleteBtn);
    taskList.appendChild(li);
}

// Event listeners
addBtn.addEventListener('click', addTask);

// Handle Enter key in input
taskInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        addTask();
    }
});
