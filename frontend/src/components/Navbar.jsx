import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { useCart } from "../context/CartContext";
import { Menu, X, ShoppingCart, User, LogOut, LayoutDashboard } from "lucide-react";
import GlobalSearch from "./GlobalSearch";

const navLinks = [
  { to: "/", label: "Home" },
  { to: "/about", label: "About Us" },
  { to: "/donation", label: "Donation" },
  { to: "/shop", label: "Shop" },
  { to: "/contact", label: "Contact Us" },
];

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const { user, logout } = useAuth();
  const { count } = useCart();
  const navigate = useNavigate();

  const dashPath = user?.role === "admin" ? "/admin/dashboard" : user?.role === "reseller" ? "/reseller/dashboard" : null;

  const handleLogout = () => {
    logout();
    navigate("/");
    setMenuOpen(false);
  };

  return (
    <nav className="sticky top-0 z-50 backdrop-blur-2xl bg-surface-deep/30 border-b border-cyan-500/20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-20">
          <Link to="/" className="flex items-center gap-3">
            <img src="/logo.jpeg" alt="Village NetAcad" className="h-16 w-auto object-contain" />
            <div>
              <span className="font-black text-xl tracking-widest bg-gradient-to-r from-cyan-400 to-purple-500 bg-clip-text text-transparent">Village Netacad</span>
              <p className="text-[9px] tracking-wide text-cyan-200/70">Village Netacad powered by Digititan</p>
            </div>
          </Link>

          <div className="hidden md:flex items-center gap-8">
            {navLinks.map((l) => (
              <Link key={l.to} to={l.to} className="text-sm font-semibold uppercase tracking-widest text-gray-300 hover:text-cyan-400 transition duration-300">{l.label}</Link>
            ))}
          </div>

          <div className="flex items-center gap-3">
            <GlobalSearch />

            <Link to="/cart" className="p-2 rounded-xl hover:bg-white/10 transition-colors relative text-gray-300 hover:text-cyan-400">
              <ShoppingCart size={18} />
              {count > 0 && <span className="absolute -top-1 -right-1 bg-gradient-to-r from-cyan-500 to-purple-600 text-white text-xs w-5 h-5 rounded-full flex items-center justify-center font-bold">{count}</span>}
            </Link>

            {user ? (
              <div className="relative">
                <button onClick={() => setMenuOpen(!menuOpen)} className="flex items-center gap-2 p-2 rounded-xl hover:bg-white/10 transition-colors">
                  <div className="w-8 h-8 bg-gradient-to-r from-cyan-500 to-purple-600 rounded-full flex items-center justify-center">
                    <span className="text-white text-sm font-bold">{user.name?.[0]?.toUpperCase()}</span>
                  </div>
                  <span className="hidden sm:block text-sm font-semibold text-gray-200">{user.name}</span>
                </button>
                {menuOpen && (
                  <div className="absolute right-0 mt-2 w-56 bg-surface-deep/90 backdrop-blur-2xl rounded-2xl shadow-[0_0_40px_rgba(0,255,255,0.1)] border border-cyan-500/20 py-2 z-50">
                    <div className="px-4 py-2 border-b border-white/10">
                      <p className="text-sm font-bold text-white">{user.name}</p>
                      <p className="text-xs text-gray-400">{user.email}</p>
                      <span className="inline-block mt-1 text-xs bg-cyan-500/20 text-cyan-300 px-2 py-0.5 rounded-full capitalize">{user.role}</span>
                    </div>
                    {dashPath && (
                      <Link to={dashPath} onClick={() => setMenuOpen(false)} className="flex items-center gap-2 px-4 py-2 text-sm text-gray-300 hover:bg-cyan-500/10 hover:text-cyan-400 transition-colors">
                        <LayoutDashboard size={16} /> Dashboard
                      </Link>
                    )}
                    <Link to="/my-orders" onClick={() => setMenuOpen(false)} className="flex items-center gap-2 px-4 py-2 text-sm text-gray-300 hover:bg-cyan-500/10 hover:text-cyan-400 transition-colors">
                      <User size={16} /> My Orders
                    </Link>
                    <button onClick={handleLogout} className="w-full flex items-center gap-2 px-4 py-2 text-sm text-red-400 hover:bg-red-500/10 transition-colors">
                      <LogOut size={16} /> Logout
                    </button>
                  </div>
                )}
              </div>
            ) : (
              <div className="hidden sm:flex items-center gap-3">
                <Link to="/login" className="text-sm font-semibold text-gray-300 hover:text-cyan-400 px-3 py-2 transition-colors">Login</Link>
                <Link to="/register" className="text-sm font-bold px-5 py-2 rounded-xl bg-gradient-to-r from-cyan-500 to-purple-600 hover:scale-105 transition-all duration-300 shadow-[0_0_20px_rgba(0,255,255,0.2)]">Register</Link>
              </div>
            )}

            <button onClick={() => setOpen(!open)} className="md:hidden p-2 rounded-xl hover:bg-white/10 text-gray-300">
              {open ? <X size={20} /> : <Menu size={20} />}
            </button>
          </div>
        </div>
      </div>

      {open && (
        <div className="md:hidden border-t border-cyan-500/20 bg-surface-deep/90 backdrop-blur-2xl px-4 py-4 space-y-2">
          {navLinks.map((l) => (
            <Link key={l.to} to={l.to} onClick={() => setOpen(false)} className="block py-2 text-sm font-semibold text-gray-300 hover:text-cyan-400 transition-colors uppercase tracking-wider">{l.label}</Link>
          ))}
          {!user && (
            <div className="flex gap-2 pt-2">
              <Link to="/login" onClick={() => setOpen(false)} className="text-sm text-center flex-1 py-2 border border-cyan-400/30 rounded-xl text-gray-300 hover:bg-cyan-500/10 transition-colors">Login</Link>
              <Link to="/register" onClick={() => setOpen(false)} className="text-sm text-center flex-1 py-2 rounded-xl bg-gradient-to-r from-cyan-500 to-purple-600 font-bold">Register</Link>
            </div>
          )}
        </div>
      )}
    </nav>
  );
}
