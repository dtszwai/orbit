import React, { useState, useEffect } from "react";
import {
  Play,
  Pause,
  SkipForward,
  Wind,
  Leaf,
  Zap,
  Coffee,
  Moon,
  Volume2,
  ChevronLeft,
  ChevronRight,
  Settings,
  MoreHorizontal,
  CheckCircle,
  Plus,
  List,
  Trash2,
  Clock,
  Calendar as CalendarIcon,
} from "lucide-react";

// --- Components ---

/**
 * Menu Bar (Micro-Orbit)
 */
const MenuBar = ({ timeFormatted, isRunning, togglePopover, isPopoverOpen }) => {
  return (
    <div className="w-full h-8 bg-black/40 backdrop-blur-md flex items-center justify-between px-4 fixed top-0 left-0 z-50 text-xs font-medium text-white border-b border-white/5 select-none shadow-sm transition-all duration-300">
      <div className="flex items-center gap-4">
        <span className="font-bold"></span>
        <span className="font-bold">Orbit</span>
        <span className="hidden sm:inline text-white/50 hover:text-white cursor-default">File</span>
        <span className="hidden sm:inline text-white/50 hover:text-white cursor-default">Window</span>
      </div>

      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2 text-white/50 hidden sm:flex">
          <Wind size={12} />
          <span>68°F</span>
        </div>

        <button
          onClick={togglePopover}
          className={`flex items-center gap-2 px-3 py-1 rounded transition-all duration-200 ${
            isPopoverOpen ? "bg-white/20 text-white" : "hover:bg-white/10 text-white/90"
          }`}
        >
          <Leaf size={14} className={`transition-colors ${isRunning ? "text-teal-400" : "text-white/80"}`} />
          <span className={`font-mono tracking-wider ${isRunning ? "animate-pulse-slow" : ""}`}>{timeFormatted}</span>
        </button>

        <span className="text-white/90">
          {new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
        </span>
      </div>
    </div>
  );
};

/**
 * Circular Sound Button
 */
const SoundCircle = ({ icon: Icon, label, isActive, colorClass, onClick }) => (
  <button onClick={onClick} className="flex flex-col items-center gap-2 group">
    <div
      className={`w-14 h-14 rounded-full border flex items-center justify-center transition-all duration-500 ease-out ${
        isActive
          ? `border-${colorClass}-400 bg-${colorClass}-400/20 text-${colorClass}-400 scale-105 shadow-[0_0_15px_rgba(0,0,0,0.3)]`
          : "border-white/10 text-white/30 group-hover:border-white/30 group-hover:text-white"
      }`}
    >
      <Icon size={24} strokeWidth={1.5} />
    </div>
    <span
      className={`text-[10px] font-medium tracking-wide transition-colors ${
        isActive ? "text-white" : "text-white/30 group-hover:text-white/60"
      }`}
    >
      {label}
    </span>
  </button>
);

/**
 * Main Application
 */
export default function OrbitApp() {
  const [isPopoverOpen, setPopoverOpen] = useState(true);
  const [activeTab, setActiveTab] = useState("controls"); // controls, tasks, stats
  const [timeLeft, setTimeLeft] = useState(25 * 60);
  const [isRunning, setIsRunning] = useState(false);
  const [activeSound, setActiveSound] = useState("focus");
  const [volume, setVolume] = useState(75);

  // Task State
  const [currentTask, setCurrentTask] = useState(null);
  const [newTaskInput, setNewTaskInput] = useState("");
  const [newTaskDuration, setNewTaskDuration] = useState(25);
  const [isAddingTask, setIsAddingTask] = useState(false);
  const [tasks, setTasks] = useState([
    { id: 1, title: "Review PRs", duration: 20, completed: false },
    { id: 2, title: "Study React Server Components", duration: 45, completed: false },
    { id: 3, title: "Write Documentation", duration: 30, completed: true },
  ]);

  // Timer Logic
  useEffect(() => {
    let interval;
    if (isRunning && timeLeft > 0) {
      interval = setInterval(() => {
        setTimeLeft((prev) => prev - 1);
      }, 1000);
    } else if (timeLeft === 0) {
      setIsRunning(false);
    }
    return () => clearInterval(interval);
  }, [isRunning, timeLeft]);

  const formatTime = (seconds) => {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${m.toString().padStart(2, "0")}:${s.toString().padStart(2, "0")}`;
  };

  const toggleTimer = () => setIsRunning(!isRunning);

  // Task Handlers
  const handleAddTask = () => {
    if (!newTaskInput.trim()) return;
    const newTask = {
      id: Date.now(),
      title: newTaskInput,
      duration: parseInt(newTaskDuration),
      completed: false,
    };
    setTasks([...tasks, newTask]);
    setNewTaskInput("");
    setIsAddingTask(false);
  };

  const importCalendarEvents = () => {
    const calendarEvents = [
      { id: Date.now() + 1, title: "Team Sync", duration: 30, completed: false, source: "calendar" },
      { id: Date.now() + 2, title: "Project Kickoff", duration: 60, completed: false, source: "calendar" },
    ];
    setTasks([...tasks, ...calendarEvents]);
  };

  const startTask = (task) => {
    setCurrentTask(task);
    setTimeLeft(task.duration * 60);
    setActiveTab("controls");
    setIsRunning(false);
  };

  const toggleTaskCompletion = (id) => {
    setTasks(tasks.map((t) => (t.id === id ? { ...t, completed: !t.completed } : t)));
  };

  const deleteTask = (id) => {
    setTasks(tasks.filter((t) => t.id !== id));
  };

  return (
    <div className="min-h-screen bg-transparent font-sans text-white overflow-hidden relative selection:bg-teal-500/30">
      {/* Background Simulation */}
      <div className="absolute inset-0 bg-gradient-to-br from-indigo-950/40 to-black/80 z-0 pointer-events-none">
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 text-white/5 text-9xl font-bold select-none">
          macOS
        </div>
      </div>

      <MenuBar
        timeFormatted={formatTime(timeLeft)}
        isRunning={isRunning}
        togglePopover={() => setPopoverOpen(!isPopoverOpen)}
        isPopoverOpen={isPopoverOpen}
      />

      {/* --- POPOVER WINDOW --- */}
      <div
        className={`
        fixed top-10 right-4 
        w-[340px] 
        bg-[#121212]
        border border-white/10 
        rounded-2xl shadow-2xl 
        transition-all duration-300 ease-[cubic-bezier(0.16,1,0.3,1)]
        origin-top-right
        z-50
        flex flex-col
        max-h-[600px]
        ${
          isPopoverOpen
            ? "opacity-100 scale-100 translate-y-0"
            : "opacity-0 scale-95 -translate-y-2 pointer-events-none"
        }
      `}
      >
        {/* Header Toggle */}
        <div className="pt-4 px-4 flex items-center justify-between flex-shrink-0">
          <div className="bg-[#1a1a1a] rounded-lg p-1 flex items-center gap-1">
            {["Controls", "Tasks", "Stats"].map((tab) => {
              const id = tab.toLowerCase();
              const isActive = activeTab === id;
              return (
                <button
                  key={id}
                  onClick={() => setActiveTab(id)}
                  className={`px-3 py-1.5 rounded-md text-xs font-medium transition-all duration-200 ${
                    isActive ? "bg-[#2a2a2a] text-white shadow-sm" : "text-white/40 hover:text-white/70"
                  }`}
                >
                  {tab}
                </button>
              );
            })}
          </div>
          <div className="flex gap-3 text-white/30">
            <Settings size={16} className="hover:text-white cursor-pointer transition-colors" />
            <div className="text-[10px] hover:text-white cursor-pointer transition-colors pt-0.5">Quit</div>
          </div>
        </div>

        {/* Content Area */}
        <div className="p-6 flex-1 overflow-y-auto custom-scrollbar">
          {/* VIEW: CONTROLS */}
          {activeTab === "controls" && (
            <div className="animate-in fade-in slide-in-from-left-4 duration-500 space-y-8">
              {/* Timer Section */}
              <div className="text-center space-y-4">
                <div
                  className={`text-xs font-bold tracking-[0.2em] uppercase transition-colors duration-500 ${
                    isRunning ? "text-teal-400" : "text-white/30"
                  }`}
                >
                  {currentTask && isRunning ? (
                    <span className="flex items-center justify-center gap-2 animate-pulse">
                      <Zap size={12} /> {currentTask.title}
                    </span>
                  ) : isRunning ? (
                    "Flow State Active"
                  ) : (
                    "Ready to Flow"
                  )}
                </div>

                <div className="relative">
                  <div
                    className={`absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-48 h-48 rounded-full bg-teal-500/5 blur-3xl transition-opacity duration-1000 ${
                      isRunning ? "opacity-100" : "opacity-0"
                    }`}
                  ></div>
                  <div className="text-7xl font-light font-mono tracking-tighter text-white relative z-10">
                    {formatTime(timeLeft)}
                  </div>
                </div>

                {/* Main Action Button */}
                <button
                  onClick={toggleTimer}
                  className={`
                    w-full py-4 rounded-xl text-sm font-semibold tracking-wide shadow-lg transition-all duration-200 hover:scale-[1.02] active:scale-[0.98]
                    flex items-center justify-center gap-2 group
                    ${
                      isRunning
                        ? "bg-[#1a1a1a] text-red-400 border border-red-500/20 hover:bg-red-500/10"
                        : "bg-teal-500 text-black hover:bg-teal-400"
                    }
                  `}
                >
                  {isRunning ? (
                    <>
                      <Pause size={16} fill="currentColor" /> Pause Session
                    </>
                  ) : (
                    <>
                      <Play size={16} fill="currentColor" /> Start Focus
                    </>
                  )}
                </button>

                {/* Volume Slider */}
                <div className="flex items-center gap-3 px-1 pt-2">
                  <Volume2 size={14} className="text-white/30" />
                  <div className="h-1 flex-1 bg-[#2a2a2a] rounded-full relative cursor-pointer group">
                    <div
                      className="absolute inset-y-0 left-0 bg-white/20 rounded-full group-hover:bg-white/40 transition-all duration-300"
                      style={{ width: `${volume}%` }}
                    ></div>
                    <div
                      className="absolute top-1/2 -translate-y-1/2 w-3 h-3 bg-white rounded-full shadow-md opacity-0 group-hover:opacity-100 transition-opacity"
                      style={{ left: `${volume}%` }}
                    ></div>
                    <input
                      type="range"
                      min="0"
                      max="100"
                      value={volume}
                      onChange={(e) => setVolume(e.target.value)}
                      className="absolute inset-0 w-full opacity-0 cursor-pointer"
                    />
                  </div>
                </div>
              </div>

              {/* Soundscapes Grid */}
              <div className="pt-2 border-t border-white/5">
                <div className="flex justify-between items-center mb-4">
                  <span className="text-xs font-medium text-white/50">Soundscape</span>
                  <MoreHorizontal size={14} className="text-white/30" />
                </div>
                <div className="flex justify-between px-2">
                  <SoundCircle
                    icon={Zap}
                    label="Deep Work"
                    colorClass="teal"
                    isActive={activeSound === "focus"}
                    onClick={() => setActiveSound("focus")}
                  />
                  <SoundCircle
                    icon={Wind}
                    label="Natural"
                    colorClass="green"
                    isActive={activeSound === "natural"}
                    onClick={() => setActiveSound("natural")}
                  />
                  <SoundCircle
                    icon={Moon}
                    label="Spatial"
                    colorClass="purple"
                    isActive={activeSound === "spatial"}
                    onClick={() => setActiveSound("spatial")}
                  />
                  <SoundCircle
                    icon={Coffee}
                    label="Relax"
                    colorClass="amber"
                    isActive={activeSound === "relax"}
                    onClick={() => setActiveSound("relax")}
                  />
                </div>
              </div>
            </div>
          )}

          {/* VIEW: TASKS */}
          {activeTab === "tasks" && (
            <div className="animate-in fade-in slide-in-from-right-4 duration-300 space-y-4">
              <div className="flex items-center justify-between mb-2">
                <h3 className="text-xs font-bold uppercase tracking-widest text-white/40">Today's Mission</h3>
                <div className="flex gap-2">
                  {/* Calendar Import Button */}
                  <button
                    onClick={importCalendarEvents}
                    className="p-1.5 rounded hover:bg-white/10 text-white/40 hover:text-blue-400 transition-colors"
                    title="Sync Calendar"
                  >
                    <CalendarIcon size={16} />
                  </button>
                  <button
                    onClick={() => setIsAddingTask(!isAddingTask)}
                    className="p-1.5 rounded hover:bg-white/10 text-teal-400 transition-colors"
                  >
                    <Plus size={16} />
                  </button>
                </div>
              </div>

              {/* Add Task Form */}
              {isAddingTask && (
                <div className="bg-[#1a1a1a] p-3 rounded-xl border border-white/10 space-y-3 mb-4 animate-in slide-in-from-top-2">
                  <input
                    autoFocus
                    type="text"
                    placeholder="Task name..."
                    className="w-full bg-black/30 border border-white/10 rounded px-3 py-2 text-sm text-white placeholder-white/30 focus:outline-none focus:border-teal-500/50 transition-colors"
                    value={newTaskInput}
                    onChange={(e) => setNewTaskInput(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && handleAddTask()}
                  />
                  <div className="flex items-center gap-2">
                    <div className="flex-1 flex items-center gap-2 bg-black/30 border border-white/10 rounded px-3 py-1.5">
                      <Clock size={14} className="text-white/40" />
                      <input
                        type="number"
                        min="1"
                        max="180"
                        className="w-full bg-transparent text-sm text-white focus:outline-none"
                        value={newTaskDuration}
                        onChange={(e) => setNewTaskDuration(e.target.value)}
                      />
                      <span className="text-xs text-white/40">min</span>
                    </div>
                    <button
                      onClick={handleAddTask}
                      className="px-4 py-1.5 bg-teal-500/20 text-teal-400 text-xs font-medium rounded border border-teal-500/20 hover:bg-teal-500/30 transition-colors"
                    >
                      Add
                    </button>
                  </div>
                </div>
              )}

              {/* Task List */}
              <div className="space-y-2">
                {tasks.length === 0 && !isAddingTask && (
                  <div className="text-center py-8 text-white/20 text-sm">No tasks yet. Add one to start flowing.</div>
                )}

                {tasks.map((task) => (
                  <div
                    key={task.id}
                    className={`group flex items-center justify-between p-3 rounded-xl border transition-all duration-200 ${
                      task.completed
                        ? "bg-white/5 border-transparent opacity-50"
                        : "bg-[#1a1a1a] border-white/5 hover:border-white/10 hover:bg-[#222]"
                    } ${
                      currentTask?.id === task.id && isRunning
                        ? "border-teal-500/30 bg-teal-500/5 shadow-[0_0_10px_rgba(45,212,191,0.05)]"
                        : ""
                    }`}
                  >
                    <div className="flex items-center gap-3 flex-1 overflow-hidden">
                      <button
                        onClick={() => toggleTaskCompletion(task.id)}
                        className={`flex-shrink-0 transition-colors ${
                          task.completed ? "text-teal-500" : "text-white/20 hover:text-white/40"
                        }`}
                      >
                        <CheckCircle
                          size={18}
                          fill={task.completed ? "currentColor" : "none"}
                          className={task.completed ? "text-black" : ""}
                        />
                      </button>
                      <div className="flex flex-col min-w-0">
                        <span
                          className={`text-sm font-medium truncate ${
                            task.completed ? "line-through text-white/40" : "text-white/90"
                          }`}
                        >
                          {task.title}
                        </span>
                        <div className="flex items-center gap-2">
                          {task.source === "calendar" && <CalendarIcon size={8} className="text-blue-400" />}
                          <span className="text-[10px] text-white/40">{task.duration} min</span>
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center gap-1 pl-2">
                      {!task.completed && (
                        <button
                          onClick={() => startTask(task)}
                          className="p-2 rounded-lg text-white/20 hover:text-teal-400 hover:bg-teal-500/10 transition-all opacity-0 group-hover:opacity-100"
                          title="Start this task"
                        >
                          <Play size={14} fill="currentColor" />
                        </button>
                      )}
                      <button
                        onClick={() => deleteTask(task.id)}
                        className="p-2 rounded-lg text-white/20 hover:text-red-400 hover:bg-red-500/10 transition-all opacity-0 group-hover:opacity-100"
                      >
                        <Trash2 size={14} />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* VIEW: STATS (Rolled Back to Heatmap) */}
          {activeTab === "stats" && (
            <div className="animate-in fade-in slide-in-from-right-4 duration-300 space-y-6">
              {/* Header */}
              <div className="flex items-center justify-between text-white/60">
                <button className="p-1 hover:bg-white/10 rounded transition-colors">
                  <ChevronLeft size={16} />
                </button>
                <span className="text-xs font-medium">Nov 22 - Nov 29</span>
                <button className="p-1 hover:bg-white/10 rounded transition-colors">
                  <ChevronRight size={16} />
                </button>
              </div>

              <div className="text-center">
                <div className="text-[10px] font-bold tracking-widest text-white/30 uppercase mb-1">Total Focus</div>
                <div className="text-5xl font-mono text-white tracking-tight">14h 20m</div>
              </div>

              {/* Heatmap Grid (Original Logic) */}
              <div className="space-y-2">
                <div className="grid grid-cols-7 gap-2 h-32">
                  {[...Array(7)].map((_, colIndex) => (
                    <div key={colIndex} className="flex flex-col gap-2">
                      {[...Array(3)].map((_, rowIndex) => {
                        const intensity = Math.random();
                        let bgClass = "bg-[#1a1a1a]";
                        if (intensity > 0.7) bgClass = "bg-teal-500";
                        else if (intensity > 0.4) bgClass = "bg-teal-500/40";
                        else if (intensity > 0.2) bgClass = "bg-[#2a2a2a]";

                        return (
                          <div
                            key={rowIndex}
                            className={`flex-1 rounded-sm ${bgClass} transition-all hover:opacity-80`}
                          ></div>
                        );
                      })}
                    </div>
                  ))}
                </div>
                <div className="grid grid-cols-7 text-center">
                  {["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((d) => (
                    <div key={d} className="text-[10px] text-white/30">
                      {d}
                    </div>
                  ))}
                </div>
              </div>

              <div className="flex items-center justify-center gap-4 text-[9px] text-white/20 uppercase tracking-widest mt-4 border-t border-white/5 pt-4">
                <span>Morning</span> • <span>Afternoon</span> • <span>Evening</span>
              </div>
            </div>
          )}
        </div>

        {/* Footer: Bio-Rhythm */}
        {activeTab === "controls" && (
          <div className="mt-auto bg-[#0a0a0a] p-4 border-t border-white/5 rounded-b-2xl flex-shrink-0">
            <div className="flex items-center gap-3 mb-2">
              <div className="w-5 h-5 rounded-full border border-white/20 flex items-center justify-center">
                <Leaf size={10} className="text-white/60" />
              </div>
              <span className="text-sm font-medium text-white/90">Afternoon Energy Decay</span>
            </div>

            <div className="flex justify-between items-end text-[10px] text-white/40">
              <div className="space-y-1">
                <div>
                  Recharge in <span className="text-teal-400">27m</span>
                </div>
                <div>
                  Peak focus <span className="text-white/60">1h 17m</span>
                </div>
              </div>
              <div className="text-right">
                <div className="text-white/60">Vancouver</div>
                <div>Rain • Sunset 17:40</div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
